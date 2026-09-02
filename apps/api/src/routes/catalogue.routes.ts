import { Router } from 'express';

import type { CatalogueController } from '../controllers/catalogue.controller.js';
import { validateQuery } from '../middleware/validate.js';
import { eventsQuerySchema } from '../schemas/events.schema.js';

/** Browse endpoints — docs/backend-api.md §2. */
export function sportsRoutes(controller: CatalogueController): Router {
  const router = Router();
  router.get('/', controller.sports);
  return router;
}

export function eventsRoutes(controller: CatalogueController): Router {
  const router = Router();
  router.get('/', validateQuery(eventsQuerySchema), controller.events);
  return router;
}
