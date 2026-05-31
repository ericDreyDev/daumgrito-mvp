import { randomUUID } from "node:crypto";
import { db } from "../database/connection.js";

export function createPayment(input: any) {
  const id = randomUUID();
  db.prepare(
    `INSERT INTO payments (id, service_request_id, amount, payment_method, status)
     VALUES (?, ?, ?, ?, ?)
     ON CONFLICT(service_request_id) DO UPDATE SET
       amount = excluded.amount,
       payment_method = excluded.payment_method,
       status = excluded.status`
  ).run(id, input.serviceRequestId, input.amount, input.paymentMethod, input.status ?? "pendente");
  return findPaymentByServiceRequest(input.serviceRequestId);
}

export function findPaymentByServiceRequest(serviceRequestId: string) {
  return db.prepare("SELECT * FROM payments WHERE service_request_id = ?").get(serviceRequestId);
}
