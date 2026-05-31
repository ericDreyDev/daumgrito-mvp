import Database from "better-sqlite3";
import bcrypt from "bcryptjs";
import { env } from "../config/env.js";
import { demoProviders, serviceCategories } from "./seed.js";

export const db = new Database(env.databasePath);
db.pragma("foreign_keys = ON");

export function initializeDatabase() {
  db.exec(`
    CREATE TABLE IF NOT EXISTS users (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE,
      phone TEXT NOT NULL,
      password_hash TEXT NOT NULL,
      city TEXT NOT NULL,
      neighborhood TEXT NOT NULL,
      user_type TEXT NOT NULL CHECK (user_type IN ('client', 'provider')),
      created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS service_categories (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL UNIQUE
    );

    CREATE TABLE IF NOT EXISTS provider_profiles (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL UNIQUE,
      photo_url TEXT,
      services TEXT NOT NULL DEFAULT '[]',
      professional_description TEXT,
      availability TEXT,
      average_price TEXT,
      average_rating REAL NOT NULL DEFAULT 0,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    );

    CREATE TABLE IF NOT EXISTS service_requests (
      id TEXT PRIMARY KEY,
      client_id TEXT NOT NULL,
      provider_id TEXT NOT NULL,
      service TEXT NOT NULL,
      description TEXT NOT NULL,
      desired_date TEXT NOT NULL,
      location_neighborhood TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'Solicitado',
      created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (client_id) REFERENCES users(id),
      FOREIGN KEY (provider_id) REFERENCES provider_profiles(id)
    );

    CREATE TABLE IF NOT EXISTS chat_messages (
      id TEXT PRIMARY KEY,
      service_request_id TEXT NOT NULL,
      sender_id TEXT NOT NULL,
      message TEXT NOT NULL,
      created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (service_request_id) REFERENCES service_requests(id) ON DELETE CASCADE,
      FOREIGN KEY (sender_id) REFERENCES users(id)
    );

    CREATE TABLE IF NOT EXISTS reviews (
      id TEXT PRIMARY KEY,
      provider_id TEXT NOT NULL,
      client_id TEXT NOT NULL,
      service_request_id TEXT NOT NULL,
      rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
      comment TEXT,
      created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (provider_id) REFERENCES provider_profiles(id),
      FOREIGN KEY (client_id) REFERENCES users(id),
      FOREIGN KEY (service_request_id) REFERENCES service_requests(id)
    );

    CREATE TABLE IF NOT EXISTS payments (
      id TEXT PRIMARY KEY,
      service_request_id TEXT NOT NULL UNIQUE,
      amount REAL NOT NULL,
      payment_method TEXT NOT NULL CHECK (payment_method IN ('Pix', 'cartão', 'dinheiro')),
      status TEXT NOT NULL DEFAULT 'pendente' CHECK (status IN ('pendente', 'pago', 'cancelado')),
      created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (service_request_id) REFERENCES service_requests(id) ON DELETE CASCADE
    );
  `);

  const insert = db.prepare("INSERT OR IGNORE INTO service_categories (id, name) VALUES (?, ?)");
  serviceCategories.forEach((category) => insert.run(category.id, category.name));

  seedDemoProviders();
}

function seedDemoProviders() {
  const passwordHash = bcrypt.hashSync("demo123", 10);
  const insertUser = db.prepare(
    `INSERT OR IGNORE INTO users
     (id, name, email, phone, password_hash, city, neighborhood, user_type)
     VALUES (?, ?, ?, ?, ?, ?, ?, 'provider')`
  );
  const insertProfile = db.prepare(
    `INSERT OR IGNORE INTO provider_profiles
     (id, user_id, services, professional_description, availability, average_price, average_rating)
     VALUES (?, ?, ?, ?, ?, ?, ?)`
  );

  demoProviders.forEach((provider) => {
    insertUser.run(
      provider.userId,
      provider.name,
      provider.email,
      provider.phone,
      passwordHash,
      provider.city,
      provider.neighborhood
    );
    insertProfile.run(
      provider.profileId,
      provider.userId,
      JSON.stringify(provider.services),
      provider.professionalDescription,
      provider.availability,
      provider.averagePrice,
      provider.averageRating
    );
  });
}
