import { randomUUID } from "node:crypto";
import { db } from "../database/connection.js";
import type { AuthUser, UserType } from "../models/types.js";

interface UserRow {
  id: string;
  name: string;
  email: string;
  phone: string;
  password_hash: string;
  city: string;
  neighborhood: string;
  user_type: UserType;
}

function toAuthUser(row: UserRow): AuthUser {
  return {
    id: row.id,
    name: row.name,
    email: row.email,
    phone: row.phone,
    city: row.city,
    neighborhood: row.neighborhood,
    userType: row.user_type
  };
}

export function createUser(input: Omit<AuthUser, "id"> & { passwordHash: string }) {
  const id = randomUUID();
  db.prepare(
    `INSERT INTO users (id, name, email, phone, password_hash, city, neighborhood, user_type)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?)`
  ).run(id, input.name, input.email, input.phone, input.passwordHash, input.city, input.neighborhood, input.userType);
  return findUserById(id)!;
}

export function findUserByEmail(email: string) {
  return db.prepare("SELECT * FROM users WHERE email = ?").get(email) as UserRow | undefined;
}

export function findUserById(id: string) {
  const row = db.prepare("SELECT * FROM users WHERE id = ?").get(id) as UserRow | undefined;
  return row ? toAuthUser(row) : undefined;
}

export function updateUser(id: string, input: Partial<Omit<AuthUser, "id" | "email" | "userType">>) {
  const current = findUserById(id);
  if (!current) return undefined;

  db.prepare(
    `UPDATE users SET name = ?, phone = ?, city = ?, neighborhood = ? WHERE id = ?`
  ).run(
    input.name ?? current.name,
    input.phone ?? current.phone,
    input.city ?? current.city,
    input.neighborhood ?? current.neighborhood,
    id
  );

  return findUserById(id);
}

export function publicUserFromRow(row: UserRow) {
  return toAuthUser(row);
}
