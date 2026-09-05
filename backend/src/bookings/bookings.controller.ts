import { Controller, Get, Post, Body } from '@nestjs/common';
import { BookingsService } from './bookings.service';
import { Booking } from './booking.entity';

@Controller('bookings')
export class BookingsController {
    constructor(private readonly bookingsService: BookingsService) { }

    @Get()
    findAll(): Promise<Booking[]> {
        return this.bookingsService.findAll();
    }

    @Post()
    create(@Body() bookingData: Partial<Booking>): Promise<Booking> {
        return this.bookingsService.create(bookingData);
    }
}
