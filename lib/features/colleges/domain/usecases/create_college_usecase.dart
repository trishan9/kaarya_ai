import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/colleges/data/repositories/college_repository.dart';
import 'package:kaarya/features/colleges/domain/entities/college_entity.dart';
import 'package:kaarya/features/colleges/domain/repositories/college_repository.dart';

final createCollegeUseCaseProvider = Provider<CreateCollegeUseCase>((ref) {
  return CreateCollegeUseCase(repository: ref.read(collegeRepositoryProvider));
});

class CreateCollegeUseCaseParams extends Equatable {
  final String name;
  final String institutionType;
  final String location;
  final String? logoPath;

  const CreateCollegeUseCaseParams({
    required this.name,
    required this.institutionType,
    required this.location,
    this.logoPath,
  });

  @override
  List<Object?> get props => [name, institutionType, location, logoPath];
}

class CreateCollegeUseCase
    implements UseCaseWithParams<CollegeEntity, CreateCollegeUseCaseParams> {
  final ICollegeRepository _repository;

  CreateCollegeUseCase({required ICollegeRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, CollegeEntity>> call(
    CreateCollegeUseCaseParams params,
  ) {
    return _repository.createCollege(
      name: params.name,
      institutionType: params.institutionType,
      location: params.location,
      logoPath: params.logoPath,
    );
  }
}
