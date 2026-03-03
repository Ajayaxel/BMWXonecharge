import 'package:equatable/equatable.dart';

abstract class CompanyCodeEvent extends Equatable {
  const CompanyCodeEvent();

  @override
  List<Object> get props => [];
}

class ValidateCompanyCode extends CompanyCodeEvent {
  final String code;

  const ValidateCompanyCode(this.code);

  @override
  List<Object> get props => [code];
}

class ResetCompanyCode extends CompanyCodeEvent {}
