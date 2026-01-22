import 'package:equatable/equatable.dart';

abstract class IssueCategoryEvent extends Equatable {
  const IssueCategoryEvent();

  @override
  List<Object> get props => [];
}

class FetchIssueCategories extends IssueCategoryEvent {}
