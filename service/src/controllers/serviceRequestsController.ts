import type { Request, Response } from "express";
import { z } from "zod";
import {
  createServiceRequest,
  findServiceRequestById,
  listServiceRequests,
  updateServiceRequestStatus
} from "../repositories/serviceRequestsRepository.js";
import { AppError } from "../utils/errors.js";
import { routeParam } from "../utils/http.js";

const createSchema = z.object({
  providerId: z.string().uuid(),
  service: z.string().min(2),
  description: z.string().min(10),
  desiredDate: z.string().min(8),
  locationNeighborhood: z.string().min(2)
});

const statusSchema = z.object({
  status: z.enum(["Solicitado", "Em negociação", "Agendado", "Em andamento", "Concluído", "Cancelado"])
});

export function postServiceRequest(req: Request, res: Response) {
  if (req.user!.userType !== "client") {
    throw new AppError(403, "Apenas clientes podem criar solicitações.");
  }

  const input = createSchema.parse(req.body);
  return res.status(201).json(createServiceRequest(req.user!.id, input));
}

export function getServiceRequests(req: Request, res: Response) {
  return res.json(listServiceRequests(req.user!.id, req.user!.userType));
}

export function getServiceRequest(req: Request, res: Response) {
  const serviceRequest = findServiceRequestById(routeParam(req.params.id, "id"));
  if (!serviceRequest) throw new AppError(404, "Solicitação não encontrada.");
  return res.json(serviceRequest);
}

export function putServiceRequestStatus(req: Request, res: Response) {
  const { status } = statusSchema.parse(req.body);
  const serviceRequest = updateServiceRequestStatus(routeParam(req.params.id, "id"), status);
  if (!serviceRequest) throw new AppError(404, "Solicitação não encontrada.");
  return res.json(serviceRequest);
}
