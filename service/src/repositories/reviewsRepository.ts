import { randomUUID } from "node:crypto";
import { db } from "../database/connection.js";

export async function createReview(clientId: string, input: any) {
  const id = randomUUID();
  const result = await db.query(
    `INSERT INTO reviews (id, provider_id, client_id, service_request_id, rating, comment)
     VALUES ($1, $2, $3, $4, $5, $6)
     RETURNING *`,
    [id, input.providerId, clientId, input.serviceRequestId, input.rating, input.comment ?? null]
  );
  return result.rows[0];
}

export async function listProviderReviews(providerId: string) {
  const result = await db.query(
    `SELECT r.*, u.name as client_name
     FROM reviews r
     JOIN users u ON u.id = r.client_id
     WHERE provider_id = $1
     ORDER BY r.created_at DESC`,
    [providerId]
  );
  return result.rows;
}
