import jwt from "jsonwebtoken";
import { env } from "../config/env.js";
import type { AuthUser } from "../models/types.js";

export function signToken(user: AuthUser) {
  return jwt.sign({ sub: user.id, userType: user.userType }, env.jwtSecret, { expiresIn: "7d" });
}

export function verifyToken(token: string) {
  return jwt.verify(token, env.jwtSecret) as { sub: string; userType: string };
}
