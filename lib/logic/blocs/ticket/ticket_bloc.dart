import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/data/repositories/issue_repository.dart';
import 'package:onecharge/logic/blocs/ticket/ticket_event.dart';
import 'package:onecharge/logic/blocs/ticket/ticket_state.dart';

class TicketBloc extends Bloc<TicketEvent, TicketState> {
  final IssueRepository issueRepository;

  TicketBloc({required this.issueRepository}) : super(TicketInitial()) {
    on<CreateTicketRequested>(_onCreateTicketRequested);
    on<FetchTicketsRequested>(_onFetchTicketsRequested);
    on<FetchTicketDetailsRequested>(_onFetchTicketDetailsRequested);
  }

  Future<void> _onCreateTicketRequested(
    CreateTicketRequested event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketLoading());
    try {
      final response = await issueRepository.createTicket(event.request);
      
      // Print the API response to console
      print('✅ [TicketBloc] Ticket created successfully!');
      print('📦 [TicketBloc] Message: ${response.message}');
      if (response.data != null) {
        print('💳 [TicketBloc] Payment Required: ${response.data!.paymentRequired}');
        if (response.data!.paymentUrl != null) {
          print('🔗 [TicketBloc] Payment URL: ${response.data!.paymentUrl}');
        }
        if (response.data!.paymentBreakdown != null) {
          final breakdown = response.data!.paymentBreakdown!;
          print('💰 [TicketBloc] Total Amount: ${breakdown.totalAmount} ${breakdown.currency}');
        }
      }
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      emit(TicketSuccess(response));
    } catch (e) {
      print('❌ [TicketBloc] Error creating ticket: $e');
      emit(TicketError(e.toString()));
    }
  }

  Future<void> _onFetchTicketsRequested(
    FetchTicketsRequested event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketListLoading());
    try {
      final response = await issueRepository.getTickets();
      final tickets = response.data?.tickets ?? [];
      emit(TicketListLoaded(tickets));
    } catch (e) {
      emit(TicketError(e.toString()));
    }
  }

  Future<void> _onFetchTicketDetailsRequested(
    FetchTicketDetailsRequested event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketDetailLoading());
    try {
      final response = await issueRepository.getTicketDetails(event.ticketId);
      final ticket = response.data?.ticket;
      if (ticket != null) {
        emit(TicketDetailSuccess(ticket));
      } else {
        emit(TicketError('Ticket not found'));
      }
    } catch (e) {
      emit(TicketError(e.toString()));
    }
  }
}
