import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/colleges/data/repositories/college_repository.dart';
import 'package:kaarya/features/colleges/domain/entities/college_entity.dart';
import 'package:kaarya/features/colleges/domain/repositories/college_repository.dart';

final updateCollegeUseCaseProvider = Provider<UpdateCollegeUseCase>((ref) {
  return UpdateCollegeUseCase(repository: ref.read(collegeRepositoryProvider));
});

class UpdateCollegeUseCaseParams extends Equatable {
  final String collegeId;
  final String? name;
  final String? institutionType;
  final String? location;
  final String? logoPath;

  const UpdateCollegeUseCaseParams({
    required this.collegeId,
    this.name,
    this.institutionType,
    this.location,
    this.logoPath,
  });

  @override
  List<Object?> get props => [
    collegeId,
    name,
    institutionType,
    location,
    logoPath,
  ];
}

class UpdateCollegeUseCase
    implements UseCaseWithParams<CollegeEntity, UpdateCollegeUseCaseParams> {
  final ICollegeRepository _repository;

  UpdateCollegeUseCase({required ICollegeRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, CollegeEntity>> call(
    UpdateCollegeUseCaseParams params,
  ) {
    return _repository.updateCollege(
      collegeId: params.collegeId,
      name: params.name,
      institutionType: params.institutionType,
      location: params.location,
      logoPath: params.logoPath,
    );
  }
}
