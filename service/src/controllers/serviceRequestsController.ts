import type { Request, Response } from "express";
import { z } from "zod";
import { findProviderById } from "../repositories/providersRepository.js";
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
  status: z.enum([
    "Solicitado",
    "Aguardando aceite",
    "Em negociação",
    "Em negociaÃ§Ã£o",
    "Agendado",
    "Aceito",
    "Recusado",
    "Em andamento",
    "Concluído",
    "ConcluÃ­do",
    "Finalizado",
    "Cancelado"
  ])
});

export async function postServiceRequest(req: Request, res: Response) {
  if (req.user!.userType !== "client") {
    throw new AppError(403, "Apenas clientes podem criar solicitações.");
  }

  const input = createSchema.parse(req.body);
  const provider = await findProviderById(input.providerId);
  if (!provider) throw new AppError(404, "Prestador não encontrado.");
  if (provider.validationStatus !== "Aprovado" || !provider.isOnline) {
    throw new AppError(422, "Este prestador ainda não está disponível para receber solicitações.");
  }

  return res.status(201).json(await createServiceRequest(req.user!.id, input));
}

export async function getServiceRequests(req: Request, res: Response) {
  return res.json(await listServiceRequests(req.user!.id, req.user!.userType));
}

export async function getServiceRequest(req: Request, res: Response) {
  const serviceRequest = await findServiceRequestById(routeParam(req.params.id, "id"));
  if (!serviceRequest) throw new AppError(404, "Solicitação não encontrada.");
  return res.json(serviceRequest);
}

export async function putServiceRequestStatus(req: Request, res: Response) {
  const { status } = statusSchema.parse(req.body);
  const requestId = routeParam(req.params.id, "id");
  const current = await findServiceRequestById(requestId);
  if (!current) throw new AppError(404, "Solicitação não encontrada.");

  const isClientOwner = current.client_id === req.user!.id;
  const isProviderOwner = current.provider_user_id === req.user!.id;
  if (!isClientOwner && !isProviderOwner) {
    throw new AppError(403, "Você não tem permissão para alterar esta solicitação.");
  }

  if (req.user!.userType === "client" && status !== "Cancelado") {
    throw new AppError(403, "Clientes podem cancelar solicitações, mas não alterar o fluxo do atendimento.");
  }

  const serviceRequest = await updateServiceRequestStatus(requestId, status);
  if (!serviceRequest) throw new AppError(404, "Solicitação não encontrada.");
  return res.json(serviceRequest);
}
