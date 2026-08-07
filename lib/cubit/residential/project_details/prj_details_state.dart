abstract class PrjDetailsState {}

class InitState extends PrjDetailsState {}

class SuccessState extends PrjDetailsState {
  final String message;
  SuccessState({required this.message});
}

class ErrorState extends PrjDetailsState {
  final String message;
  ErrorState({required this.message});
}

class LocationErrorState extends PrjDetailsState {
  final String message;
  LocationErrorState({required this.message});
}

class LoadingState extends PrjDetailsState {}
