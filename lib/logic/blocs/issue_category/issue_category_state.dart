import 'package:equatable/equatable.dart';
import 'package:onecharge/models/issue_category_model.dart';

abstract class IssueCategoryState extends Equatable {
  const IssueCategoryState();

  @override
  List<Object> get props => [];
}

class IssueCategoryInitial extends IssueCategoryState {}

class IssueCategoryLoading extends IssueCategoryState {}

class IssueCategoryLoaded extends IssueCategoryState {
  final List<IssueCategory> categories;

  const IssueCategoryLoaded(this.categories);

  @override
  List<Object> get props => [categories];
}

class IssueCategoryError extends IssueCategoryState {
  final String message;

  const IssueCategoryError(this.message);

  @override
  List<Object> get props => [message];
}
