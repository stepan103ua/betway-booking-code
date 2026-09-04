import { Router } from 'express';

import { BookingCodesController } from '../controllers/booking-codes.controller.js';
import { CatalogueController } from '../controllers/catalogue.controller.js';
import type { Cache } from '../lib/redis.js';
import type { BookingCodeProvider } from '../providers/booking-code-provider.js';
import { BookingCodesService } from '../services/booking-codes.service.js';
import { CatalogueService } from '../services/catalogue.service.js';

import { bookingCodeRoutes } from './booking-codes.routes.js';
import { eventsRoutes, sportsRoutes } from './catalogue.routes.js';
import { healthRoutes } from './health.routes.js';

/** Mounts the full `/api` surface from docs/backend-api.md. */
export function apiRoutes(provider: BookingCodeProvider, cache: Cache): Router {
  const bookingCodes = new BookingCodesController(new BookingCodesService(provider, cache));
  const catalogue = new CatalogueController(new CatalogueService(provider, cache));

  const router = Router();

  router.use('/health', healthRoutes(cache, provider));
  router.use('/booking-codes', bookingCodeRoutes(bookingCodes));
  router.use('/sports', sportsRoutes(catalogue));
  router.use('/events', eventsRoutes(catalogue));

  return router;
}
