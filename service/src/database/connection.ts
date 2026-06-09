import bcrypt from "bcryptjs";
import { Pool } from "pg";
import { env } from "../config/env.js";
import { demoClients, demoProviders, serviceCategories } from "./seed.js";

export const db = new Pool({
  connectionString: env.databaseUrl
});

export async function initializeDatabase() {
  await db.query(`
    CREATE TABLE IF NOT EXISTS users (
      id UUID PRIMARY KEY,
      name TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE,
      phone TEXT NOT NULL,
      document TEXT NOT NULL DEFAULT '',
      password_hash TEXT NOT NULL,
      city TEXT NOT NULL,
      neighborhood TEXT NOT NULL,
      user_type TEXT NOT NULL CHECK (user_type IN ('client', 'provider')),
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS service_categories (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL UNIQUE
    );

    CREATE TABLE IF NOT EXISTS provider_profiles (
      id UUID PRIMARY KEY,
      user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
      photo_url TEXT,
      services JSONB NOT NULL DEFAULT '[]'::jsonb,
      professional_description TEXT,
      availability TEXT,
      average_price TEXT,
      average_rating NUMERIC(3, 2) NOT NULL DEFAULT 0
    );

    CREATE TABLE IF NOT EXISTS service_requests (
      id UUID PRIMARY KEY,
      client_id UUID NOT NULL REFERENCES users(id),
      provider_id UUID NOT NULL REFERENCES provider_profiles(id),
      service TEXT NOT NULL,
      description TEXT NOT NULL,
      desired_date DATE NOT NULL,
      location_neighborhood TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'Solicitado',
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS chat_messages (
      id UUID PRIMARY KEY,
      service_request_id UUID NOT NULL REFERENCES service_requests(id) ON DELETE CASCADE,
      sender_id UUID NOT NULL REFERENCES users(id),
      message TEXT NOT NULL,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS reviews (
      id UUID PRIMARY KEY,
      provider_id UUID NOT NULL REFERENCES provider_profiles(id),
      client_id UUID NOT NULL REFERENCES users(id),
      service_request_id UUID NOT NULL REFERENCES service_requests(id),
      rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
      comment TEXT,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS payments (
      id UUID PRIMARY KEY,
      service_request_id UUID NOT NULL UNIQUE REFERENCES service_requests(id) ON DELETE CASCADE,
      amount NUMERIC(10, 2) NOT NULL,
      payment_method TEXT NOT NULL CHECK (payment_method IN ('Pix', 'cartão', 'dinheiro')),
      status TEXT NOT NULL DEFAULT 'pendente' CHECK (status IN ('pendente', 'pago', 'cancelado')),
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
  `);

  await db.query("ALTER TABLE users ADD COLUMN IF NOT EXISTS document TEXT NOT NULL DEFAULT ''");

  await seedServiceCategories();
  await seedDemoClients();
  await seedDemoProviders();
}

async function seedServiceCategories() {
  for (const category of serviceCategories) {
    await db.query("INSERT INTO service_categories (id, name) VALUES ($1, $2) ON CONFLICT (id) DO NOTHING", [
      category.id,
      category.name
    ]);
  }
}

async function seedDemoProviders() {
  const passwordHash = await bcrypt.hash("demo123", 10);

  for (const provider of demoProviders) {
    await db.query(
      `INSERT INTO users (id, name, email, phone, document, password_hash, city, neighborhood, user_type)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 'provider')
       ON CONFLICT (id) DO NOTHING`,
      [
        provider.userId,
        provider.name,
        provider.email,
        provider.phone,
        provider.document,
        passwordHash,
        provider.city,
        provider.neighborhood
      ]
    );

    await db.query(
      `INSERT INTO provider_profiles
       (id, user_id, services, professional_description, availability, average_price, average_rating)
       VALUES ($1, $2, $3::jsonb, $4, $5, $6, $7)
       ON CONFLICT (id) DO NOTHING`,
      [
        provider.profileId,
        provider.userId,
        JSON.stringify(provider.services),
        provider.professionalDescription,
        provider.availability,
        provider.averagePrice,
        provider.averageRating
      ]
    );
  }
}

async function seedDemoClients() {
  const passwordHash = await bcrypt.hash("demo123", 10);

  for (const client of demoClients) {
    await db.query(
      `INSERT INTO users (id, name, email, phone, document, password_hash, city, neighborhood, user_type)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 'client')
       ON CONFLICT (id) DO NOTHING`,
      [
        client.userId,
        client.name,
        client.email,
        client.phone,
        client.document,
        passwordHash,
        client.city,
        client.neighborhood
      ]
    );
  }
}
