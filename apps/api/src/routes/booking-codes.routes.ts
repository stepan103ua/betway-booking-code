import { Router } from 'express';

import type { BookingCodesController } from '../controllers/booking-codes.controller.js';
import { validateBody, validateQuery } from '../middleware/validate.js';
import {
  convertBodySchema,
  createBodySchema,
  popularQuerySchema,
  resolveBodySchema,
} from '../schemas/booking-codes.schema.js';

/**
 * HTTP concerns only: path, method, validation, status code. The contract these implement is
 * docs/backend-api.md §1 — check any change against it.
 *
 * No `/api/v1` prefix, deliberately (docs/backend-api.md, preamble).
 *
 * The handlers are wired but their services throw `not_implemented`, so every route answers
 * 501 in the standard `ApiError` shape until the service layer is written. The URL surface
 * and the validation are real from the first run.
 */
export function bookingCodeRoutes(controller: BookingCodesController): Router {
  const router = Router();

  router.post('/resolve', validateBody(resolveBodySchema), controller.resolve);
  router.post('/convert', validateBody(convertBodySchema), controller.convert);
  router.get('/popular', validateQuery(popularQuerySchema), controller.popular);
  router.post('/', validateBody(createBodySchema), controller.create);

  return router;
}
