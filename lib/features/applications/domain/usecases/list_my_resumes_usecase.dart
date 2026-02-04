import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/applications/data/repositories/application_repository.dart';
import 'package:kaarya/features/applications/domain/entities/resume_entity.dart';
import 'package:kaarya/features/applications/domain/repositories/application_repository.dart';

final listMyResumesUseCaseProvider = Provider<ListMyResumesUseCase>((ref) {
  final repository = ref.read(applicationRepositoryProvider);
  return ListMyResumesUseCase(repository: repository);
});

class ListMyResumesUseCaseParams extends Equatable {
  final int page;
  final int size;

  const ListMyResumesUseCaseParams({this.page = 1, this.size = 50});

  @override
  List<Object?> get props => [page, size];
}

class ListMyResumesUseCase
    implements
        UseCaseWithParams<List<ResumeEntity>, ListMyResumesUseCaseParams> {
  final IApplicationRepository _repository;

  ListMyResumesUseCase({required IApplicationRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<ResumeEntity>>> call(
    ListMyResumesUseCaseParams params,
  ) {
    return _repository.listMyResumes(page: params.page, size: params.size);
  }
}
