import 'package:equatable/equatable.dart';
import 'package:onecharge/models/ticket_model.dart';

abstract class TicketState extends Equatable {
  const TicketState();

  @override
  List<Object> get props => [];
}

class TicketInitial extends TicketState {}

class TicketLoading extends TicketState {}

class TicketSuccess extends TicketState {
  final CreateTicketResponse response;

  const TicketSuccess(this.response);

  @override
  List<Object> get props => [response];
}

class TicketError extends TicketState {
  final String message;

  const TicketError(this.message);

  @override
  List<Object> get props => [message];
}

class TicketListLoading extends TicketState {}

class TicketListLoaded extends TicketState {
  final List<Ticket> tickets;

  const TicketListLoaded(this.tickets);

  @override
  List<Object> get props => [tickets];
}

class TicketDetailLoading extends TicketState {}

class TicketDetailSuccess extends TicketState {
  final Ticket ticket;

  const TicketDetailSuccess(this.ticket);

  @override
  List<Object> get props => [ticket];
}

class InvoiceDownloadLoading extends TicketState {}

class InvoiceDownloadSuccess extends TicketState {
  final String filePath;

  const InvoiceDownloadSuccess(this.filePath);

  @override
  List<Object> get props => [filePath];
}

class InvoiceDownloadError extends TicketState {
  final String message;

  const InvoiceDownloadError(this.message);

  @override
  List<Object> get props => [message];
}

class DriverLocationLoaded extends TicketState {
  final TicketDriver? driver;

  const DriverLocationLoaded(this.driver);

  @override
  List<Object> get props => [driver ?? 'none'];
}
