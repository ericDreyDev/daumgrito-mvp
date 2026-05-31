import cors from "cors";
import express from "express";
import { errorHandler } from "./middlewares/errorHandler.js";
import { routes } from "./routes/index.js";
import { env } from "./config/env.js";

export function createApp() {
  const app = express();

  app.use(cors({ origin: env.corsOrigin }));
  app.use(express.json());
  app.get("/health", (_req, res) => res.json({ status: "ok" }));
  app.use(routes);
  app.use(errorHandler);

  return app;
}
