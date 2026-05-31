import { AppError } from "./errors.js";

export function routeParam(value: string | string[] | undefined, name: string) {
  if (typeof value !== "string") {
    throw new AppError(400, `Parâmetro inválido: ${name}.`);
  }
  return value;
}
