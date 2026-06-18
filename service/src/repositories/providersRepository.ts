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

function parseJsonList(value: unknown) {
  if (Array.isArray(value)) return value;
  if (typeof value === "string") return JSON.parse(value || "[]");
  return [];
}

function parseProvider(row: any) {
  return {
    id: row.id,
    userId: row.user_id,
    name: row.name,
    email: row.email,
    phone: row.phone,
    document: row.document,
    city: row.city,
    neighborhood: row.neighborhood,
    photoUrl: row.photo_url,
    services: parseJsonList(row.services),
    professionalDescription: row.professional_description,
    experience: row.experience,
    documents: parseJsonList(row.documents),
    selfieUrl: row.selfie_url,
    validationStatus: row.validation_status ?? "Pendente",
    baseAddress: row.base_address,
    serviceCity: row.service_city ?? row.city,
    serviceNeighborhood: row.service_neighborhood ?? row.neighborhood,
    serviceRadiusKm: Number(row.service_radius_km ?? 10),
    useCurrentLocation: Boolean(row.use_current_location),
    isOnline: Boolean(row.is_online),
    availability: row.availability,
    averagePrice: row.average_price,
    averageRating: Number(row.average_rating ?? 0),
    completedServicesCount: Number(row.completed_services_count ?? 0)
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
    `UPDATE users
     SET name = $1,
         phone = $2,
         document = $3,
         city = $4,
         neighborhood = $5
     WHERE id = $6`,
    [
      input.name,
      input.phone,
      input.document,
      input.city,
      input.neighborhood,
      userId
    ]
  );

  await db.query(
    `UPDATE provider_profiles
     SET photo_url = $1,
         services = $2::jsonb,
         professional_description = $3,
         experience = $4,
         documents = $5::jsonb,
         selfie_url = $6,
         base_address = $7,
         service_city = $8,
         service_neighborhood = $9,
         service_radius_km = $10,
         use_current_location = $11,
         is_online = $12,
         availability = $13,
         average_price = $14
     WHERE user_id = $15`,
    [
      input.photoUrl || null,
      JSON.stringify(input.services ?? []),
      input.professionalDescription,
      input.experience ?? null,
      JSON.stringify(input.documents ?? []),
      input.selfieUrl || null,
      input.baseAddress ?? null,
      input.serviceCity ?? input.city,
      input.serviceNeighborhood ?? input.neighborhood,
      input.serviceRadiusKm ?? 10,
      Boolean(input.useCurrentLocation),
      Boolean(input.isOnline),
      input.availability,
      input.averagePrice,
      userId
    ]
  );
  return findProviderByUserId(userId);
}

export async function setProviderAvailability(userId: string, isOnline: boolean) {
  await ensureProviderProfile(userId);
  await db.query("UPDATE provider_profiles SET is_online = $1 WHERE user_id = $2", [isOnline, userId]);
  return findProviderByUserId(userId);
}

export async function findProviderByUserId(userId: string) {
  const result = await db.query(`${providerSelect()} WHERE pp.user_id = $1`, [userId]);
  return result.rows[0] ? parseProvider(result.rows[0]) : undefined;
}

export async function findProviderById(id: string) {
  const result = await db.query(`${providerSelect()} WHERE pp.id = $1`, [id]);
  return result.rows[0] ? parseProvider(result.rows[0]) : undefined;
}

export async function listProviders(filters: ProviderFilters) {
  const result = await db.query(
    `${providerSelect()}
     WHERE pp.validation_status = 'Aprovado'
       AND pp.is_online = true
       AND ($1::text IS NULL OR u.name ILIKE $2)
       AND ($3::text IS NULL OR pp.services::text ILIKE $4)
       AND ($5::text IS NULL OR COALESCE(pp.service_city, u.city) ILIKE $6)
       AND ($7::text IS NULL OR COALESCE(pp.service_neighborhood, u.neighborhood) ILIKE $8)
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

function providerSelect() {
  return `
    SELECT
      pp.*,
      u.name,
      u.email,
      u.phone,
      u.document,
      u.city,
      u.neighborhood,
      (
        SELECT COUNT(*)
        FROM service_requests sr
        WHERE sr.provider_id = pp.id AND sr.status IN ('Finalizado', 'Concluído')
      ) AS completed_services_count
    FROM provider_profiles pp
    JOIN users u ON u.id = pp.user_id
  `;
}
