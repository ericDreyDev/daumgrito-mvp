import { randomUUID } from "node:crypto";
import { db } from "../database/connection.js";

export interface ProviderFilters {
  name?: string;
  service?: string;
  city?: string;
  neighborhood?: string;
  availability?: string;
  minRating?: number;
  bestRating?: boolean;
}

function parseProvider(row: any) {
  return {
    id: row.id,
    userId: row.user_id,
    name: row.name,
    email: row.email,
    phone: row.phone,
    city: row.city,
    neighborhood: row.neighborhood,
    photoUrl: row.photo_url,
    services: Array.isArray(row.services) ? row.services : JSON.parse(row.services ?? "[]"),
    professionalDescription: row.professional_description,
    availability: row.availability,
    averagePrice: row.average_price,
    averageRating: Number(row.average_rating ?? 0)
  };
}

export async function ensureProviderProfile(userId: string) {
  await db.query(
    `INSERT INTO provider_profiles (id, user_id)
     VALUES ($1, $2)
     ON CONFLICT (user_id) DO NOTHING`,
    [randomUUID(), userId]
  );
}

export async function upsertProviderProfile(userId: string, input: any) {
  await ensureProviderProfile(userId);
  await db.query(
    `UPDATE provider_profiles
     SET photo_url = $1,
         services = $2::jsonb,
         professional_description = $3,
         availability = $4,
         average_price = $5
     WHERE user_id = $6`,
    [
      input.photoUrl ?? null,
      JSON.stringify(input.services ?? []),
      input.professionalDescription ?? null,
      input.availability ?? null,
      input.averagePrice ?? null,
      userId
    ]
  );
  return findProviderByUserId(userId);
}

export async function findProviderByUserId(userId: string) {
  const result = await db.query(
    `SELECT pp.*, u.name, u.email, u.phone, u.city, u.neighborhood
     FROM provider_profiles pp
     JOIN users u ON u.id = pp.user_id
     WHERE pp.user_id = $1`,
    [userId]
  );
  return result.rows[0] ? parseProvider(result.rows[0]) : undefined;
}

export async function findProviderById(id: string) {
  const result = await db.query(
    `SELECT pp.*, u.name, u.email, u.phone, u.city, u.neighborhood
     FROM provider_profiles pp
     JOIN users u ON u.id = pp.user_id
     WHERE pp.id = $1`,
    [id]
  );
  return result.rows[0] ? parseProvider(result.rows[0]) : undefined;
}

export async function listProviders(filters: ProviderFilters) {
  const result = await db.query(
    `SELECT pp.*, u.name, u.email, u.phone, u.city, u.neighborhood
     FROM provider_profiles pp
     JOIN users u ON u.id = pp.user_id
     WHERE ($1::text IS NULL OR u.name ILIKE $2)
       AND ($3::text IS NULL OR pp.services::text ILIKE $4)
       AND ($5::text IS NULL OR u.city ILIKE $6)
       AND ($7::text IS NULL OR u.neighborhood ILIKE $8)
       AND ($9::text IS NULL OR pp.availability ILIKE $10)
       AND ($11::numeric IS NULL OR pp.average_rating >= $11)
     ORDER BY
       CASE WHEN $12::boolean THEN pp.average_rating END DESC NULLS LAST,
       u.name ASC`,
    [
      filters.name ?? null,
      filters.name ? `%${filters.name}%` : null,
      filters.service ?? null,
      filters.service ? `%${filters.service}%` : null,
      filters.city ?? null,
      filters.city ? `%${filters.city}%` : null,
      filters.neighborhood ?? null,
      filters.neighborhood ? `%${filters.neighborhood}%` : null,
      filters.availability ?? null,
      filters.availability ? `%${filters.availability}%` : null,
      filters.minRating ?? null,
      Boolean(filters.bestRating)
    ]
  );

  return result.rows.map(parseProvider);
}

export async function updateProviderRating(providerId: string) {
  const result = await db.query<{ average_rating: string | null }>(
    "SELECT AVG(rating)::numeric(3,2) as average_rating FROM reviews WHERE provider_id = $1",
    [providerId]
  );
  await db.query("UPDATE provider_profiles SET average_rating = $1 WHERE id = $2", [
    result.rows[0]?.average_rating ?? 0,
    providerId
  ]);
}
