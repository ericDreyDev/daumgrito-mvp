import type { Request, Response } from "express";
import { z } from "zod";
import {
  listPendingProviders,
  listProviderApprovalHistory,
  setProviderValidationStatus
} from "../repositories/providersRepository.js";
import { listUsers, resetUserPassword, setUserAccess } from "../repositories/usersRepository.js";
import { AppError } from "../utils/errors.js";

const providerApprovalSchema = z.object({
  status: z.enum(["Aprovado", "Reprovado"]),
  reason: z.string().max(300).optional()
});

const userAccessSchema = z.object({
  isActive: z.boolean().optional(),
  isBlocked: z.boolean().optional()
});

const resetPasswordSchema = z.object({
  password: z.string().min(6)
});

function param(value: string | string[] | undefined, name: string) {
  if (!value || Array.isArray(value)) {
    throw new AppError(400, `Parametro invalido: ${name}.`);
  }

  return value;
}

export async function getPendingProviderApprovals(_req: Request, res: Response) {
  return res.json(await listPendingProviders());
}

export async function patchProviderApproval(req: Request, res: Response) {
  const input = providerApprovalSchema.parse(req.body);
  const providerId = param(req.params.providerId, "providerId");
  const provider = await setProviderValidationStatus(
    providerId,
    req.user!.id,
    input.status,
    input.reason
  );

  if (!provider) throw new AppError(404, "Prestador nao encontrado.");

  return res.json(provider);
}

export async function getProviderApprovalHistory(_req: Request, res: Response) {
  return res.json(await listProviderApprovalHistory());
}

export async function getAdminUsers(_req: Request, res: Response) {
  return res.json(await listUsers());
}

export async function patchUserAccess(req: Request, res: Response) {
  const userId = param(req.params.userId, "userId");
  if (userId === req.user!.id) {
    throw new AppError(400, "Administrador nao pode alterar o proprio acesso.");
  }

  const input = userAccessSchema.parse(req.body);
  const user = await setUserAccess(userId, input);
  if (!user) throw new AppError(404, "Usuario nao encontrado.");

  return res.json(user);
}

export async function postUserPasswordReset(req: Request, res: Response) {
  const input = resetPasswordSchema.parse(req.body);
  const userId = param(req.params.userId, "userId");
  const user = await resetUserPassword(userId, input.password);
  if (!user) throw new AppError(404, "Usuario nao encontrado.");

  return res.json({ user });
}
