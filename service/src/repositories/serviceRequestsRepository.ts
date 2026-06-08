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
  const result =
    userType === "provider"
      ? await db.query(
          `SELECT * FROM service_requests
           WHERE provider_id IN (SELECT id FROM provider_profiles WHERE user_id = $1)
           ORDER BY created_at DESC`,
          [userId]
        )
      : await db.query("SELECT * FROM service_requests WHERE client_id = $1 ORDER BY created_at DESC", [userId]);

  return result.rows;
}

export async function findServiceRequestById(id: string) {
  const result = await db.query("SELECT * FROM service_requests WHERE id = $1", [id]);
  return result.rows[0];
}

export async function updateServiceRequestStatus(id: string, status: RequestStatus) {
  const result = await db.query("UPDATE service_requests SET status = $1 WHERE id = $2 RETURNING *", [status, id]);
  return result.rows[0];
}
