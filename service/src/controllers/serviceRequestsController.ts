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
  status: z.enum(["Aguardando aceite", "Aceito", "Recusado", "Em andamento", "Finalizado", "Cancelado"])
});

export async function postServiceRequest(req: Request, res: Response) {
  if (req.user!.userType !== "client") {
    throw new AppError(403, "Apenas clientes podem criar solicitações.");
  }

  const input = createSchema.parse(req.body);
  const serviceRequest = await createServiceRequest(req.user!.id, input);
  if (!serviceRequest) {
    throw new AppError(422, "Este prestador ainda não está aprovado e online para receber solicitações.");
  }
  return res.status(201).json(serviceRequest);
}

export async function getServiceRequests(req: Request, res: Response) {
  return res.json(await listServiceRequests(req.user!.id, req.user!.userType));
}

export async function getServiceRequest(req: Request, res: Response) {
  const serviceRequest = await findServiceRequestById(routeParam(req.params.id, "id"));
  if (!serviceRequest) throw new AppError(404, "Solicitação não encontrada.");
  if (!canAccessServiceRequest(req, serviceRequest)) {
    throw new AppError(403, "Você não tem permissão para acessar esta solicitação.");
  }
  return res.json(serviceRequest);
}

export async function putServiceRequestStatus(req: Request, res: Response) {
  if (req.user!.userType !== "provider") {
    throw new AppError(403, "Apenas prestadores podem alterar o status da solicitação.");
  }

  const { status } = statusSchema.parse(req.body);
  const id = routeParam(req.params.id, "id");
  const current = await findServiceRequestById(id);
  if (!current) throw new AppError(404, "Solicitação não encontrada.");
  if (current.provider_user_id !== req.user!.id) {
    throw new AppError(403, "Apenas o prestador responsável pode alterar esta solicitação.");
  }

  return res.json(await updateServiceRequestStatus(id, status));
}

function canAccessServiceRequest(req: Request, serviceRequest: any) {
  if (req.user!.userType === "client") return serviceRequest.client_id === req.user!.id;
  if (req.user!.userType === "provider") return serviceRequest.provider_user_id === req.user!.id;
  return false;
}
