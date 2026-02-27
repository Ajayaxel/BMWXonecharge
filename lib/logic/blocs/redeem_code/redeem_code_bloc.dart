import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/data/repositories/redeem_code_repository.dart';
import 'package:onecharge/logic/blocs/redeem_code/redeem_code_event.dart';
import 'package:onecharge/logic/blocs/redeem_code/redeem_code_state.dart';

class RedeemCodeBloc extends Bloc<RedeemCodeEvent, RedeemCodeState> {
  final RedeemCodeRepository redeemCodeRepository;
  String? _lastValidatedCode;

  RedeemCodeBloc({required this.redeemCodeRepository})
    : super(RedeemCodeInitial()) {
    on<ValidateRedeemCode>(_onValidateRedeemCode);
    on<ResetRedeemCode>(_onResetRedeemCode);
  }

  Future<void> _onValidateRedeemCode(
    ValidateRedeemCode event,
    Emitter<RedeemCodeState> emit,
  ) async {
    // Prevent duplicate submission if same valid code already applied
    if (state is RedeemCodeSuccess && _lastValidatedCode == event.code) {
      return;
    }

    emit(RedeemCodeLoading());
    try {
      final response = await redeemCodeRepository.validateCode(event.code);
      if (response.success) {
        _lastValidatedCode = event.code;
        emit(RedeemCodeSuccess(response));
      } else {
        emit(RedeemCodeFailure(response.message));
      }
    } catch (e) {
      emit(RedeemCodeFailure(e.toString()));
    }
  }

  void _onResetRedeemCode(
    ResetRedeemCode event,
    Emitter<RedeemCodeState> emit,
  ) {
    _lastValidatedCode = null;
    emit(RedeemCodeInitial());
  }
}
