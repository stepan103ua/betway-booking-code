import type { Request, Response } from 'express';

import type { BookingCodesService } from '../services/booking-codes.service.js';
import type { ConvertBody, CreateBody, ResolveBody } from '../schemas/booking-codes.schema.js';

/**
 * TODO: request in, service call, response out. Nothing else.
 *
 * No business logic, no upstream calls, no cache decisions — those belong to the service.
 * A controller that starts branching on upstream behaviour is a sign the logic landed in the
 * wrong layer.
 *
 * Bodies arriving here are already Zod-validated by the route, so they can be trusted and
 * read as typed values rather than re-checked.
 *
 * Errors are thrown, never caught-and-responded-to: Express 5 forwards a rejected promise to
 * the error middleware, which owns every error body in the service.
 */
export class BookingCodesController {
  constructor(private readonly service: BookingCodesService) {}

  resolve = async (req: Request, res: Response): Promise<void> => {
    const { code } = req.body as ResolveBody;
    res.json(await this.service.resolve(code));
  };

  create = async (req: Request, res: Response): Promise<void> => {
    const { outcomeIds } = req.body as CreateBody;
    res.json({ bookingCode: await this.service.create(outcomeIds) });
  };

  convert = async (req: Request, res: Response): Promise<void> => {
    const { code, dropOutcomeIds } = req.body as ConvertBody;
    res.json(await this.service.convert(code, dropOutcomeIds));
  };

  popular = async (_req: Request, res: Response): Promise<void> => {
    res.json({ codes: await this.service.popular(20) });
  };
}
