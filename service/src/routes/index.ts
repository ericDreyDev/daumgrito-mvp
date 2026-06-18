import { Router } from "express";
import { login, register } from "../controllers/authController.js";
import { getChatMessages, postChatMessage } from "../controllers/chatController.js";
import { getPayment, postPayment } from "../controllers/paymentsController.js";
import {
  getMyProviderProfile,
  patchProviderAvailability,
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
import { asyncHandler } from "../utils/asyncHandler.js";

export const routes = Router();

routes.post("/auth/register", asyncHandler(register));
routes.post("/auth/login", asyncHandler(login));

routes.get("/users/me", requireAuth, getMe);
routes.put("/users/me", requireAuth, asyncHandler(putMe));

routes.get("/providers", asyncHandler(getProviders));
routes.get("/providers/me", requireAuth, asyncHandler(getMyProviderProfile));
routes.get("/providers/:id", asyncHandler(getProvider));
routes.put("/providers/profile", requireAuth, asyncHandler(putProviderProfile));
routes.patch("/providers/availability", requireAuth, asyncHandler(patchProviderAvailability));

routes.post("/service-requests", requireAuth, asyncHandler(postServiceRequest));
routes.get("/service-requests", requireAuth, asyncHandler(getServiceRequests));
routes.get("/service-requests/:id", requireAuth, asyncHandler(getServiceRequest));
routes.put("/service-requests/:id/status", requireAuth, asyncHandler(putServiceRequestStatus));

routes.post("/chats/:serviceRequestId/messages", requireAuth, asyncHandler(postChatMessage));
routes.get("/chats/:serviceRequestId/messages", requireAuth, asyncHandler(getChatMessages));

routes.post("/reviews", requireAuth, asyncHandler(postReview));
routes.get("/providers/:id/reviews", asyncHandler(getProviderReviews));

routes.post("/payments", requireAuth, asyncHandler(postPayment));
routes.get("/payments/:serviceRequestId", requireAuth, asyncHandler(getPayment));
