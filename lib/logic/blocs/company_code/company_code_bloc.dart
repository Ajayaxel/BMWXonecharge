import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/data/repositories/company_code_repository.dart';
import 'package:onecharge/logic/blocs/company_code/company_code_event.dart';
import 'package:onecharge/logic/blocs/company_code/company_code_state.dart';

class CompanyCodeBloc extends Bloc<CompanyCodeEvent, CompanyCodeState> {
  final CompanyCodeRepository companyCodeRepository;
  String? _lastValidatedCode;

  CompanyCodeBloc({required this.companyCodeRepository})
    : super(CompanyCodeInitial()) {
    on<ValidateCompanyCode>(_onValidateCompanyCode);
    on<ResetCompanyCode>(_onResetCompanyCode);
  }

  Future<void> _onValidateCompanyCode(
    ValidateCompanyCode event,
    Emitter<CompanyCodeState> emit,
  ) async {
    // Prevent duplicate submission if same valid code already applied
    if (state is CompanyCodeSuccess && _lastValidatedCode == event.code) {
      return;
    }

    emit(CompanyCodeLoading());
    try {
      final response = await companyCodeRepository.validateCompanyCode(
        event.code,
      );
      if (response.success) {
        _lastValidatedCode = event.code;
        emit(CompanyCodeSuccess(response));
      } else {
        emit(CompanyCodeFailure(response.message));
      }
    } catch (e) {
      emit(CompanyCodeFailure(e.toString()));
    }
  }

  void _onResetCompanyCode(
    ResetCompanyCode event,
    Emitter<CompanyCodeState> emit,
  ) {
    _lastValidatedCode = null;
    emit(CompanyCodeInitial());
  }
}
