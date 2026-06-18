import dotenv from "dotenv";

dotenv.config();

export const env = {
  port: Number(process.env.PORT ?? 3333),
  jwtSecret: process.env.JWT_SECRET ?? "dev-secret",
  databaseUrl: process.env.DATABASE_URL ?? "postgres://daumgrito:daumgrito@localhost:5432/daumgrito",
  corsOrigins: (process.env.CORS_ORIGIN ?? "http://localhost:5173,http://localhost:*")
    .split(",")
    .map((origin) => origin.trim())
    .filter(Boolean)
};
