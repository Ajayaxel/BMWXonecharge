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
