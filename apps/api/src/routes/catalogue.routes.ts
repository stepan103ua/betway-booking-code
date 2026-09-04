import { Router } from 'express';

import type { CatalogueController } from '../controllers/catalogue.controller.js';
import { validateParams, validateQuery } from '../middleware/validate.js';
import { eventParamsSchema, eventsQuerySchema } from '../schemas/events.schema.js';

/** Browse endpoints — docs/backend-api.md §2. */
export function sportsRoutes(controller: CatalogueController): Router {
  const router = Router();
  router.get('/', controller.sports);
  return router;
}

export function eventsRoutes(controller: CatalogueController): Router {
  const router = Router();
  router.get('/', validateQuery(eventsQuerySchema), controller.events);
  router.get('/:eventId/markets', validateParams(eventParamsSchema), controller.eventMarkets);
  return router;
}
