import cors from "cors";
import express from "express";
import { errorHandler } from "./middlewares/errorHandler.js";
import { routes } from "./routes/index.js";
import { env } from "./config/env.js";

export function createApp() {
  const app = express();

  app.use(cors({ origin: isAllowedOrigin }));
  app.use(express.json());
  app.get("/health", (_req, res) => res.json({ status: "ok" }));
  app.use(routes);
  app.use(errorHandler);

  return app;
}

function isAllowedOrigin(origin: string | undefined, callback: (err: Error | null, allow?: boolean) => void) {
  if (!origin) return callback(null, true);

  const allowed = env.corsOrigins.some((allowedOrigin) => {
    if (allowedOrigin === origin) return true;
    if (allowedOrigin === "http://localhost:*") return /^http:\/\/localhost:\d+$/.test(origin);
    if (allowedOrigin === "http://127.0.0.1:*") return /^http:\/\/127\.0\.0\.1:\d+$/.test(origin);
    return false;
  });

  callback(null, allowed);
}
