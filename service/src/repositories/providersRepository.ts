import { randomUUID } from "node:crypto";
import { db } from "../database/connection.js";

export interface ProviderFilters {
  service?: string;
  city?: string;
  neighborhood?: string;
  availability?: string;
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
    services: JSON.parse(row.services ?? "[]"),
    professionalDescription: row.professional_description,
    availability: row.availability,
    averagePrice: row.average_price,
    averageRating: Number(row.average_rating ?? 0)
  };
}

export function ensureProviderProfile(userId: string) {
  const existing = db.prepare("SELECT * FROM provider_profiles WHERE user_id = ?").get(userId);
  if (!existing) {
    db.prepare("INSERT INTO provider_profiles (id, user_id) VALUES (?, ?)").run(randomUUID(), userId);
  }
}

export function upsertProviderProfile(userId: string, input: any) {
  ensureProviderProfile(userId);
  db.prepare(
    `UPDATE provider_profiles
     SET photo_url = ?, services = ?, professional_description = ?, availability = ?, average_price = ?
     WHERE user_id = ?`
  ).run(
    input.photoUrl ?? null,
    JSON.stringify(input.services ?? []),
    input.professionalDescription ?? null,
    input.availability ?? null,
    input.averagePrice ?? null,
    userId
  );
  return findProviderByUserId(userId);
}

export function findProviderByUserId(userId: string) {
  const row = db
    .prepare(
      `SELECT pp.*, u.name, u.email, u.phone, u.city, u.neighborhood
       FROM provider_profiles pp
       JOIN users u ON u.id = pp.user_id
       WHERE pp.user_id = ?`
    )
    .get(userId);
  return row ? parseProvider(row) : undefined;
}

export function findProviderById(id: string) {
  const row = db
    .prepare(
      `SELECT pp.*, u.name, u.email, u.phone, u.city, u.neighborhood
       FROM provider_profiles pp
       JOIN users u ON u.id = pp.user_id
       WHERE pp.id = ?`
    )
    .get(id);
  return row ? parseProvider(row) : undefined;
}

export function listProviders(filters: ProviderFilters) {
  const rows = db
    .prepare(
      `SELECT pp.*, u.name, u.email, u.phone, u.city, u.neighborhood
       FROM provider_profiles pp
       JOIN users u ON u.id = pp.user_id
       WHERE (? IS NULL OR pp.services LIKE ?)
         AND (? IS NULL OR LOWER(u.city) LIKE LOWER(?))
         AND (? IS NULL OR LOWER(u.neighborhood) LIKE LOWER(?))
         AND (? IS NULL OR LOWER(pp.availability) LIKE LOWER(?))
       ORDER BY
         CASE WHEN ? = 1 THEN pp.average_rating END DESC,
         u.name ASC`
    )
    .all(
      filters.service ?? null,
      filters.service ? `%${filters.service}%` : null,
      filters.city ?? null,
      filters.city ? `%${filters.city}%` : null,
      filters.neighborhood ?? null,
      filters.neighborhood ? `%${filters.neighborhood}%` : null,
      filters.availability ?? null,
      filters.availability ? `%${filters.availability}%` : null,
      filters.bestRating ? 1 : 0
    );

  return rows.map(parseProvider);
}

export function updateProviderRating(providerId: string) {
  const result = db
    .prepare("SELECT AVG(rating) as averageRating FROM reviews WHERE provider_id = ?")
    .get(providerId) as { averageRating: number | null };
  db.prepare("UPDATE provider_profiles SET average_rating = ? WHERE id = ?").run(result.averageRating ?? 0, providerId);
}
