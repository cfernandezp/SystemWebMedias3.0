import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/auth/domain/repositories/auth_repository.dart';

class ResendConfirmation {
  final AuthRepository repository;

  const ResendConfirmation(this.repository);

  Future<Either<Failure, void>> call(
    ResendConfirmationParams params,
  ) async {
    return await repository.resendConfirmation(params.email);
  }
}

class ResendConfirmationParams extends Equatable {
  final String email;

  const ResendConfirmationParams({required this.email});

  @override
  List<Object> get props => [email];
}
