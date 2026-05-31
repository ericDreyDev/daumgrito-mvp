import { randomUUID } from "node:crypto";
import { db } from "../database/connection.js";
import type { RequestStatus } from "../models/types.js";

export function createServiceRequest(clientId: string, input: any) {
  const id = randomUUID();
  db.prepare(
    `INSERT INTO service_requests
     (id, client_id, provider_id, service, description, desired_date, location_neighborhood)
     VALUES (?, ?, ?, ?, ?, ?, ?)`
  ).run(id, clientId, input.providerId, input.service, input.description, input.desiredDate, input.locationNeighborhood);
  return findServiceRequestById(id);
}

export function listServiceRequests(userId: string, userType: string) {
  const where =
    userType === "provider"
      ? "provider_id IN (SELECT id FROM provider_profiles WHERE user_id = ?)"
      : "client_id = ?";
  return db.prepare(`SELECT * FROM service_requests WHERE ${where} ORDER BY created_at DESC`).all(userId);
}

export function findServiceRequestById(id: string) {
  return db.prepare("SELECT * FROM service_requests WHERE id = ?").get(id);
}

export function updateServiceRequestStatus(id: string, status: RequestStatus) {
  db.prepare("UPDATE service_requests SET status = ? WHERE id = ?").run(status, id);
  return findServiceRequestById(id);
}
