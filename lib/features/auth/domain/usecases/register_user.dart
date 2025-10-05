import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/auth/data/models/auth_response_model.dart';
import 'package:system_web_medias/features/auth/data/models/register_request_model.dart';
import 'package:system_web_medias/features/auth/domain/repositories/auth_repository.dart';

class RegisterUser {
  final AuthRepository repository;

  const RegisterUser(this.repository);

  Future<Either<Failure, AuthResponseModel>> call(
    RegisterUserParams params,
  ) async {
    return await repository.register(params.request);
  }
}

class RegisterUserParams extends Equatable {
  final RegisterRequestModel request;

  const RegisterUserParams({required this.request});

  @override
  List<Object> get props => [request];
}
