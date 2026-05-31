import { randomUUID } from "node:crypto";
import { db } from "../database/connection.js";

export function createReview(clientId: string, input: any) {
  const id = randomUUID();
  db.prepare(
    `INSERT INTO reviews (id, provider_id, client_id, service_request_id, rating, comment)
     VALUES (?, ?, ?, ?, ?, ?)`
  ).run(id, input.providerId, clientId, input.serviceRequestId, input.rating, input.comment ?? null);
  return db.prepare("SELECT * FROM reviews WHERE id = ?").get(id);
}

export function listProviderReviews(providerId: string) {
  return db
    .prepare(
      `SELECT r.*, u.name as client_name
       FROM reviews r
       JOIN users u ON u.id = r.client_id
       WHERE provider_id = ?
       ORDER BY r.created_at DESC`
    )
    .all(providerId);
}
