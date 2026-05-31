import type { Request, Response } from "express";
import { z } from "zod";
import { createPayment, findPaymentByServiceRequest } from "../repositories/paymentsRepository.js";
import { AppError } from "../utils/errors.js";
import { routeParam } from "../utils/http.js";

const paymentSchema = z.object({
  serviceRequestId: z.string().uuid(),
  amount: z.number().positive(),
  paymentMethod: z.enum(["Pix", "cartão", "dinheiro"]),
  status: z.enum(["pendente", "pago", "cancelado"]).optional()
});

export function postPayment(req: Request, res: Response) {
  const input = paymentSchema.parse(req.body);
  return res.status(201).json(createPayment(input));
}

export function getPayment(req: Request, res: Response) {
  const payment = findPaymentByServiceRequest(routeParam(req.params.serviceRequestId, "serviceRequestId"));
  if (!payment) throw new AppError(404, "Pagamento não encontrado.");
  return res.json(payment);
}
