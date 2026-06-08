import { randomUUID } from "node:crypto";
import { db } from "../database/connection.js";

export async function createChatMessage(serviceRequestId: string, senderId: string, message: string) {
  const id = randomUUID();
  const result = await db.query(
    `INSERT INTO chat_messages (id, service_request_id, sender_id, message)
     VALUES ($1, $2, $3, $4)
     RETURNING *`,
    [id, serviceRequestId, senderId, message]
  );
  return result.rows[0];
}

export async function listChatMessages(serviceRequestId: string) {
  const result = await db.query(
    `SELECT cm.*, u.name as sender_name
     FROM chat_messages cm
     JOIN users u ON u.id = cm.sender_id
     WHERE service_request_id = $1
     ORDER BY cm.created_at ASC`,
    [serviceRequestId]
  );
  return result.rows;
}
