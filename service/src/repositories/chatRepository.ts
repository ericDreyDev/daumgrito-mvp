import { randomUUID } from "node:crypto";
import { db } from "../database/connection.js";

export function createChatMessage(serviceRequestId: string, senderId: string, message: string) {
  const id = randomUUID();
  db.prepare(
    "INSERT INTO chat_messages (id, service_request_id, sender_id, message) VALUES (?, ?, ?, ?)"
  ).run(id, serviceRequestId, senderId, message);
  return db.prepare("SELECT * FROM chat_messages WHERE id = ?").get(id);
}

export function listChatMessages(serviceRequestId: string) {
  return db
    .prepare(
      `SELECT cm.*, u.name as sender_name
       FROM chat_messages cm
       JOIN users u ON u.id = cm.sender_id
       WHERE service_request_id = ?
       ORDER BY cm.created_at ASC`
    )
    .all(serviceRequestId);
}
