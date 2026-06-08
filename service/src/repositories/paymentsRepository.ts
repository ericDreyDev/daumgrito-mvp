import { randomUUID } from "node:crypto";
import { db } from "../database/connection.js";

export async function createPayment(input: any) {
  const result = await db.query(
    `INSERT INTO payments (id, service_request_id, amount, payment_method, status)
     VALUES ($1, $2, $3, $4, $5)
     ON CONFLICT (service_request_id) DO UPDATE SET
       amount = EXCLUDED.amount,
       payment_method = EXCLUDED.payment_method,
       status = EXCLUDED.status
     RETURNING *`,
    [randomUUID(), input.serviceRequestId, input.amount, input.paymentMethod, input.status ?? "pendente"]
  );
  return result.rows[0];
}

export async function findPaymentByServiceRequest(serviceRequestId: string) {
  const result = await db.query("SELECT * FROM payments WHERE service_request_id = $1", [serviceRequestId]);
  return result.rows[0];
}
