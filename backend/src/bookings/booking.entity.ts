import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn } from 'typeorm';

@Entity()
export class Booking {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column()
    serviceType: string;

    @Column()
    clientName: string;

    @Column()
    date: string;

    @Column()
    time: string;

    @Column({ default: 'pending' })
    status: string; // pending, confirmed, completed

    @CreateDateColumn()
    createdAt: Date;
}
