import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/auth/data/models/email_confirmation_response_model.dart';
import 'package:system_web_medias/features/auth/domain/repositories/auth_repository.dart';

class ConfirmEmail {
  final AuthRepository repository;

  const ConfirmEmail(this.repository);

  Future<Either<Failure, EmailConfirmationResponseModel>> call(
    ConfirmEmailParams params,
  ) async {
    return await repository.confirmEmail(params.token);
  }
}

class ConfirmEmailParams extends Equatable {
  final String token;

  const ConfirmEmailParams({required this.token});

  @override
  List<Object> get props => [token];
}
