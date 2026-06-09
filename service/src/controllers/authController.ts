import bcrypt from "bcryptjs";
import type { Request, Response } from "express";
import { z } from "zod";
import { ensureProviderProfile } from "../repositories/providersRepository.js";
import { createUser, findUserByEmail, publicUserFromRow } from "../repositories/usersRepository.js";
import { AppError } from "../utils/errors.js";
import { signToken } from "../utils/tokens.js";

const registerSchema = z.object({
  name: z.string().min(2),
  email: z.string().email().transform((value) => value.toLowerCase()),
  phone: z.string().min(8),
  document: z.string().min(6),
  password: z.string().min(6),
  city: z.string().min(2),
  neighborhood: z.string().min(2),
  userType: z.enum(["client", "provider"])
});

const loginSchema = z.object({
  email: z.string().email().transform((value) => value.toLowerCase()),
  password: z.string().min(1)
});

export async function register(req: Request, res: Response) {
  const input = registerSchema.parse(req.body);

  if (await findUserByEmail(input.email)) {
    throw new AppError(409, "Este e-mail já está cadastrado.");
  }

  const passwordHash = await bcrypt.hash(input.password, 10);
  const user = await createUser({ ...input, passwordHash });

  if (user.userType === "provider") {
    await ensureProviderProfile(user.id);
  }

  return res.status(201).json({ user, token: signToken(user) });
}

export async function login(req: Request, res: Response) {
  const input = loginSchema.parse(req.body);
  const userRow = await findUserByEmail(input.email);

  if (!userRow || !(await bcrypt.compare(input.password, userRow.password_hash))) {
    throw new AppError(401, "E-mail ou senha inválidos.");
  }

  const user = publicUserFromRow(userRow);
  return res.json({ user, token: signToken(user) });
}
