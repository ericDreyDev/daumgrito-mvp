import type { Request, Response } from "express";
import { z } from "zod";
import {
  findProviderById,
  findProviderByUserId,
  listProviders,
  setProviderAvailability,
  upsertProviderProfile
} from "../repositories/providersRepository.js";
import { listProviderReviews } from "../repositories/reviewsRepository.js";
import { AppError } from "../utils/errors.js";
import { routeParam } from "../utils/http.js";

const profileSchema = z.object({
  name: z.string().min(2),
  phone: z.string().min(8),
  document: z.string().min(6),
  city: z.string().min(2),
  neighborhood: z.string().min(2),
  photoUrl: z.string().url().optional().or(z.literal("")),
  services: z.array(z.string().min(2)).min(1),
  professionalDescription: z.string().min(10),
  experience: z.string().optional(),
  documents: z.array(z.string().min(2)).default([]),
  selfieUrl: z.string().url().optional().or(z.literal("")),
  baseAddress: z.string().optional(),
  serviceCity: z.string().min(2),
  serviceNeighborhood: z.string().min(2),
  serviceRadiusKm: z.number().int().min(1).max(100),
  useCurrentLocation: z.boolean().default(false),
  isOnline: z.boolean().default(false),
  availability: z.string().min(2),
  averagePrice: z.string().min(1)
});

const availabilitySchema = z.object({
  isOnline: z.boolean()
});

export async function getProviders(req: Request, res: Response) {
  const providers = await listProviders({
    name: req.query.name?.toString(),
    service: req.query.service?.toString(),
    city: req.query.city?.toString(),
    neighborhood: req.query.neighborhood?.toString(),
    availability: req.query.availability?.toString(),
    minRating: req.query.minRating ? Number(req.query.minRating) : undefined,
    bestRating: req.query.bestRating === "true"
  });
  return res.json(providers);
}

export async function getProvider(req: Request, res: Response) {
  const provider = await findProviderById(routeParam(req.params.id, "id"));
  if (!provider) throw new AppError(404, "Prestador não encontrado.");
  return res.json(provider);
}

export async function putProviderProfile(req: Request, res: Response) {
  if (req.user!.userType !== "provider") {
    throw new AppError(403, "Apenas prestadores podem editar o perfil profissional.");
  }

  const input = profileSchema.parse(req.body);
  const provider = await upsertProviderProfile(req.user!.id, input);
  return res.json(provider);
}

export async function patchProviderAvailability(req: Request, res: Response) {
  if (req.user!.userType !== "provider") {
    throw new AppError(403, "Apenas prestadores podem alterar disponibilidade.");
  }

  const { isOnline } = availabilitySchema.parse(req.body);
  return res.json(await setProviderAvailability(req.user!.id, isOnline));
}

export async function getMyProviderProfile(req: Request, res: Response) {
  if (req.user!.userType !== "provider") {
    throw new AppError(403, "Apenas prestadores acessam este perfil.");
  }

  const provider = await findProviderByUserId(req.user!.id);
  if (!provider) throw new AppError(404, "Perfil de prestador não encontrado.");
  return res.json(provider);
}

export async function getProviderReviews(req: Request, res: Response) {
  return res.json(await listProviderReviews(routeParam(req.params.id, "id")));
}
