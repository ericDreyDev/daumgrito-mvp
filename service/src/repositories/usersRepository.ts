import { randomUUID } from "node:crypto";
import { db } from "../database/connection.js";
import type { AuthUser, UserType } from "../models/types.js";
import { AppError } from "../utils/errors.js";

export interface UserRow {
  id: string;
  name: string;
  email: string;
  phone: string;
  document: string;
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
    document: row.document,
    city: row.city,
    neighborhood: row.neighborhood,
    userType: row.user_type
  };
}

export async function createUser(input: Omit<AuthUser, "id"> & { passwordHash: string }) {
  const id = randomUUID();
  await db.query(
    `INSERT INTO users (id, name, email, phone, document, password_hash, city, neighborhood, user_type)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
    [id, input.name, input.email, input.phone, input.document, input.passwordHash, input.city, input.neighborhood, input.userType]
  );
  const user = await findUserById(id);
  if (!user) throw new AppError(500, "Usuário criado, mas não encontrado.");
  return user;
}

export async function findUserByEmail(email: string) {
  const result = await db.query<UserRow>("SELECT * FROM users WHERE email = $1", [email]);
  return result.rows[0];
}

export async function findUserById(id: string) {
  const result = await db.query<UserRow>("SELECT * FROM users WHERE id = $1", [id]);
  const row = result.rows[0];
  return row ? toAuthUser(row) : undefined;
}

export async function updateUser(id: string, input: Partial<Omit<AuthUser, "id" | "userType">>) {
  const current = await findUserById(id);
  if (!current) return undefined;

  await db.query(
    `UPDATE users
     SET name = $1,
         email = $2,
         phone = $3,
         document = $4,
         city = $5,
         neighborhood = $6
     WHERE id = $7`,
    [
      input.name ?? current.name,
      input.email ?? current.email,
      input.phone ?? current.phone,
      input.document ?? current.document,
      input.city ?? current.city,
      input.neighborhood ?? current.neighborhood,
      id
    ]
  );

  return findUserById(id);
}

export function publicUserFromRow(row: UserRow) {
  return toAuthUser(row);
}
