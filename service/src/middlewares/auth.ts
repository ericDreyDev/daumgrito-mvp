import type { NextFunction, Request, Response } from "express";
import { findUserById } from "../repositories/usersRepository.js";
import { AppError } from "../utils/errors.js";
import { verifyToken } from "../utils/tokens.js";

declare global {
  namespace Express {
    interface Request {
      user?: ReturnType<typeof findUserById>;
    }
  }
}

export function requireAuth(req: Request, _res: Response, next: NextFunction) {
  const header = req.headers.authorization;
  const token = header?.startsWith("Bearer ") ? header.slice(7) : null;

  if (!token) throw new AppError(401, "Token de autenticação não informado.");

  try {
    const payload = verifyToken(token);
    const user = findUserById(payload.sub);
    if (!user) throw new AppError(401, "Usuário não encontrado.");
    req.user = user;
    next();
  } catch {
    throw new AppError(401, "Token inválido ou expirado.");
  }
}
