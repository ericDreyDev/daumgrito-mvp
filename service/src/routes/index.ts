import { Router } from "express";
import { login, register } from "../controllers/authController.js";
import { getChatMessages, postChatMessage } from "../controllers/chatController.js";
import { getPayment, postPayment } from "../controllers/paymentsController.js";
import {
  getMyProviderProfile,
  getProvider,
  getProviderReviews,
  getProviders,
  putProviderProfile
} from "../controllers/providersController.js";
import { postReview } from "../controllers/reviewsController.js";
import {
  getServiceRequest,
  getServiceRequests,
  postServiceRequest,
  putServiceRequestStatus
} from "../controllers/serviceRequestsController.js";
import { getMe, putMe } from "../controllers/usersController.js";
import { requireAuth } from "../middlewares/auth.js";

export const routes = Router();

routes.post("/auth/register", register);
routes.post("/auth/login", login);

routes.get("/users/me", requireAuth, getMe);
routes.put("/users/me", requireAuth, putMe);

routes.get("/providers", getProviders);
routes.get("/providers/me", requireAuth, getMyProviderProfile);
routes.get("/providers/:id", getProvider);
routes.put("/providers/profile", requireAuth, putProviderProfile);

routes.post("/service-requests", requireAuth, postServiceRequest);
routes.get("/service-requests", requireAuth, getServiceRequests);
routes.get("/service-requests/:id", requireAuth, getServiceRequest);
routes.put("/service-requests/:id/status", requireAuth, putServiceRequestStatus);

routes.post("/chats/:serviceRequestId/messages", requireAuth, postChatMessage);
routes.get("/chats/:serviceRequestId/messages", requireAuth, getChatMessages);

routes.post("/reviews", requireAuth, postReview);
routes.get("/providers/:id/reviews", getProviderReviews);

routes.post("/payments", requireAuth, postPayment);
routes.get("/payments/:serviceRequestId", requireAuth, getPayment);
