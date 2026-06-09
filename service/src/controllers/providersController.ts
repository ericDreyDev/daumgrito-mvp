import type { Request, Response } from "express";
import { z } from "zod";
import {
  findProviderById,
  findProviderByUserId,
  listProviders,
  upsertProviderProfile
} from "../repositories/providersRepository.js";
import { listProviderReviews } from "../repositories/reviewsRepository.js";
import { AppError } from "../utils/errors.js";
import { routeParam } from "../utils/http.js";

const profileSchema = z.object({
  photoUrl: z.string().url().optional().or(z.literal("")),
  services: z.array(z.string().min(2)).min(1),
  professionalDescription: z.string().min(10),
  availability: z.string().min(2),
  averagePrice: z.string().min(1)
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
  const provider = await upsertProviderProfile(req.user!.id, { ...input, photoUrl: input.photoUrl || null });
  return res.json(provider);
}

export async function getMyProviderProfile(req: Request, res: Response) {
  const provider = await findProviderByUserId(req.user!.id);
  if (!provider) throw new AppError(404, "Perfil de prestador não encontrado.");
  return res.json(provider);
}

export async function getProviderReviews(req: Request, res: Response) {
  return res.json(await listProviderReviews(routeParam(req.params.id, "id")));
}
