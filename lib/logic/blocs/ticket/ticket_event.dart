import 'package:equatable/equatable.dart';
import 'package:onecharge/models/ticket_model.dart';

abstract class TicketEvent extends Equatable {
  const TicketEvent();

  @override
  List<Object> get props => [];
}

class CreateTicketRequested extends TicketEvent {
  final CreateTicketRequest request;

  const CreateTicketRequested(this.request);

  @override
  List<Object> get props => [request];
}

class FetchTicketsRequested extends TicketEvent {
  const FetchTicketsRequested();
}

class FetchTicketDetailsRequested extends TicketEvent {
  final int ticketId;

  const FetchTicketDetailsRequested(this.ticketId);

  @override
  List<Object> get props => [ticketId];
}

class DownloadInvoiceRequested extends TicketEvent {
  final int ticketId;

  const DownloadInvoiceRequested(this.ticketId);

  @override
  List<Object> get props => [ticketId];
}

class FetchDriverLocationRequested extends TicketEvent {
  final int ticketId;

  const FetchDriverLocationRequested(this.ticketId);

  @override
  List<Object> get props => [ticketId];
}

class UpdateDriverLocation extends TicketEvent {
  final TicketDriver driver;

  const UpdateDriverLocation(this.driver);

  @override
  List<Object> get props => [driver];
}

class UpdateTicketDetails extends TicketEvent {
  final Ticket ticket;

  const UpdateTicketDetails(this.ticket);

  @override
  List<Object> get props => [ticket];
}
