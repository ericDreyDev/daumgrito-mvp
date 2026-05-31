import type { Request, Response } from "express";
import { z } from "zod";
import { updateUser } from "../repositories/usersRepository.js";
import { AppError } from "../utils/errors.js";

const updateUserSchema = z.object({
  name: z.string().min(2).optional(),
  phone: z.string().min(8).optional(),
  city: z.string().min(2).optional(),
  neighborhood: z.string().min(2).optional()
});

export function getMe(req: Request, res: Response) {
  return res.json(req.user);
}

export function putMe(req: Request, res: Response) {
  const input = updateUserSchema.parse(req.body);
  const user = updateUser(req.user!.id, input);
  if (!user) throw new AppError(404, "Usuário não encontrado.");
  return res.json(user);
}
