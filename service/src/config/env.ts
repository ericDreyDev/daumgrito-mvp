import dotenv from "dotenv";

dotenv.config();

export const env = {
  port: Number(process.env.PORT ?? 3333),
  jwtSecret: process.env.JWT_SECRET ?? "dev-secret",
  databasePath: process.env.DATABASE_PATH ?? "./database.sqlite",
  corsOrigin: process.env.CORS_ORIGIN ?? "http://localhost:5173"
};
