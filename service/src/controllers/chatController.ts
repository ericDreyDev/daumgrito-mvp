import type { Request, Response } from "express";
import { z } from "zod";
import { createChatMessage, listChatMessages } from "../repositories/chatRepository.js";
import { routeParam } from "../utils/http.js";

const messageSchema = z.object({
  message: z.string().min(1).max(1000)
});

export async function postChatMessage(req: Request, res: Response) {
  const { message } = messageSchema.parse(req.body);
  return res.status(201).json(await createChatMessage(routeParam(req.params.serviceRequestId, "serviceRequestId"), req.user!.id, message));
}

export async function getChatMessages(req: Request, res: Response) {
  return res.json(await listChatMessages(routeParam(req.params.serviceRequestId, "serviceRequestId")));
}
