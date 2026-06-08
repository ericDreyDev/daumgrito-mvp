import { createApp } from "./app.js";
import { env } from "./config/env.js";
import { initializeDatabase } from "./database/connection.js";

await initializeDatabase();

const app = createApp();

app.listen(env.port, () => {
  console.log(`Dá um grito! API rodando em http://localhost:${env.port}`);
});
