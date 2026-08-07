abstract class CProjectDetailsState {}

class InitState extends CProjectDetailsState {}

class ErrorState extends CProjectDetailsState {
  final String message;
  ErrorState({required this.message});
}
