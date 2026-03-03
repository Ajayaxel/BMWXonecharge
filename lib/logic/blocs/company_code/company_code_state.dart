import 'package:equatable/equatable.dart';
import 'package:onecharge/models/company_code_model.dart';

abstract class CompanyCodeState extends Equatable {
  const CompanyCodeState();

  @override
  List<Object> get props => [];
}

class CompanyCodeInitial extends CompanyCodeState {}

class CompanyCodeLoading extends CompanyCodeState {}

class CompanyCodeSuccess extends CompanyCodeState {
  final CompanyCodeResponse response;

  const CompanyCodeSuccess(this.response);

  @override
  List<Object> get props => [response];
}

class CompanyCodeFailure extends CompanyCodeState {
  final String error;

  const CompanyCodeFailure(this.error);

  @override
  List<Object> get props => [error];
}
