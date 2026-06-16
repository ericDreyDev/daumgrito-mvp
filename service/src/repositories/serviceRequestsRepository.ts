import { randomUUID } from "node:crypto";
import { db } from "../database/connection.js";
import type { RequestStatus } from "../models/types.js";

export async function createServiceRequest(clientId: string, input: any) {
  const id = randomUUID();
  await db.query(
    `INSERT INTO service_requests
     (id, client_id, provider_id, service, description, desired_date, location_neighborhood)
     VALUES ($1, $2, $3, $4, $5, $6, $7)`,
    [id, clientId, input.providerId, input.service, input.description, input.desiredDate, input.locationNeighborhood]
  );
  return findServiceRequestById(id);
}

export async function listServiceRequests(userId: string, userType: string) {
  const where =
    userType === "provider"
      ? "sr.provider_id IN (SELECT id FROM provider_profiles WHERE user_id = $1)"
      : "sr.client_id = $1";

  const result = await db.query(`${serviceRequestSelect()} WHERE ${where} ORDER BY sr.created_at DESC`, [userId]);

  return result.rows;
}

export async function findServiceRequestById(id: string) {
  const result = await db.query(`${serviceRequestSelect()} WHERE sr.id = $1`, [id]);
  return result.rows[0];
}

export async function updateServiceRequestStatus(id: string, status: RequestStatus) {
  await db.query("UPDATE service_requests SET status = $1 WHERE id = $2", [status, id]);
  return findServiceRequestById(id);
}

function serviceRequestSelect() {
  return `
    SELECT
      sr.*,
      provider_user.name AS provider_name,
      provider_user.phone AS provider_phone,
      provider_user.city AS provider_city,
      provider_user.neighborhood AS provider_neighborhood,
      pp.user_id AS provider_user_id,
      pp.photo_url AS provider_photo_url,
      pp.services AS provider_services,
      pp.professional_description AS provider_professional_description,
      pp.availability AS provider_availability,
      pp.average_price AS provider_average_price,
      pp.average_rating AS provider_average_rating,
      client_user.name AS client_name,
      client_user.phone AS client_phone,
      client_user.city AS client_city,
      client_user.neighborhood AS client_neighborhood,
      EXISTS (
        SELECT 1 FROM reviews r WHERE r.service_request_id = sr.id
      ) AS reviewed
    FROM service_requests sr
    JOIN provider_profiles pp ON pp.id = sr.provider_id
    JOIN users provider_user ON provider_user.id = pp.user_id
    JOIN users client_user ON client_user.id = sr.client_id
  `;
}
