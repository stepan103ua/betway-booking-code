import type { Request, Response } from 'express';

import { validatedParams, validatedQuery } from '../middleware/validate.js';
import type { EventParams, EventsQuery } from '../schemas/events.schema.js';
import type { CatalogueService } from '../services/catalogue.service.js';

/** TODO: see the note in `booking-codes.controller.ts` — same rules apply. */
export class CatalogueController {
  constructor(private readonly service: CatalogueService) {}

  sports = async (_req: Request, res: Response): Promise<void> => {
    res.json({ sports: await this.service.sports() });
  };

  events = async (_req: Request, res: Response): Promise<void> => {
    const { sport, take } = validatedQuery<EventsQuery>(res);
    res.json({ events: await this.service.events(sport, take) });
  };

  eventMarkets = async (_req: Request, res: Response): Promise<void> => {
    const { eventId } = validatedParams<EventParams>(res);
    res.json({ eventId, markets: await this.service.eventMarkets(eventId) });
  };
}
