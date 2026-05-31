import type { Request, Response } from "express";
import { z } from "zod";
import { updateProviderRating } from "../repositories/providersRepository.js";
import { createReview } from "../repositories/reviewsRepository.js";
import { AppError } from "../utils/errors.js";

const reviewSchema = z.object({
  providerId: z.string().uuid(),
  serviceRequestId: z.string().uuid(),
  rating: z.number().int().min(1).max(5),
  comment: z.string().max(500).optional()
});

export function postReview(req: Request, res: Response) {
  if (req.user!.userType !== "client") {
    throw new AppError(403, "Apenas clientes podem avaliar prestadores.");
  }

  const input = reviewSchema.parse(req.body);
  const review = createReview(req.user!.id, input);
  updateProviderRating(input.providerId);
  return res.status(201).json(review);
}
