import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/jobs/data/repositories/job_repository.dart';
import 'package:kaarya/features/jobs/domain/repositories/job_repository.dart';
import 'package:kaarya/features/jobs/domain/usecases/create_job_usecase.dart';
import 'package:kaarya/features/jobs/domain/usecases/delete_job_usecase.dart';
import 'package:kaarya/features/jobs/domain/usecases/get_job_detail_usecase.dart';
import 'package:kaarya/features/jobs/domain/usecases/get_job_metrics_usecase.dart';
import 'package:kaarya/features/jobs/domain/usecases/get_jobs_section_usecase.dart';
import 'package:kaarya/features/jobs/domain/usecases/record_job_view_usecase.dart';
import 'package:kaarya/features/jobs/domain/usecases/update_job_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_fixtures.dart';

class MockJobRepository extends Mock implements IJobRepository {}

void main() {
  late MockJobRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockJobRepository();
    container = ProviderContainer(
      overrides: [jobRepositoryProvider.overrideWithValue(mockRepository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('job usecase providers should resolve', () {
    expect(
      container.read(getJobsSectionUseCaseProvider),
      isA<GetJobsSectionUseCase>(),
    );
    expect(
      container.read(getJobDetailUseCaseProvider),
      isA<GetJobDetailUseCase>(),
    );
    expect(
      container.read(recordJobViewUseCaseProvider),
      isA<RecordJobViewUseCase>(),
    );
    expect(container.read(createJobUseCaseProvider), isA<CreateJobUseCase>());
    expect(container.read(updateJobUseCaseProvider), isA<UpdateJobUseCase>());
    expect(container.read(deleteJobUseCaseProvider), isA<DeleteJobUseCase>());
    expect(
      container.read(getJobMetricsUseCaseProvider),
      isA<GetJobMetricsUseCase>(),
    );
  });

  test('GetJobsSectionUseCase should pass filters to repository', () async {
    final expected = buildJobsSectionEntity();
    when(
      () => mockRepository.getJobsSection(
        searchQuery: any(named: 'searchQuery'),
        locationQuery: any(named: 'locationQuery'),
        status: any(named: 'status'),
        employmentType: any(named: 'employmentType'),
        engagementType: any(named: 'engagementType'),
      ),
    ).thenAnswer((_) async => Right(expected));

    final usecase = GetJobsSectionUseCase(repository: mockRepository);
    final result = await usecase(
      const GetJobsSectionParams(
        searchQuery: 'flutter',
        locationQuery: 'kathmandu',
        status: 'open',
        employmentType: 'Full-time',
        engagementType: 'Internship',
      ),
    );

    expect(result, Right(expected));
    verify(
      () => mockRepository.getJobsSection(
        searchQuery: 'flutter',
        locationQuery: 'kathmandu',
        status: 'open',
        employmentType: 'Full-time',
        engagementType: 'Internship',
      ),
    ).called(1);
  });

  test('GetJobDetailUseCase should pass id to repository', () async {
    final expected = buildJobDetailEntity();
    when(
      () => mockRepository.getJobDetail(any()),
    ).thenAnswer((_) async => Right(expected));

    final usecase = GetJobDetailUseCase(repository: mockRepository);
    final result = await usecase(const GetJobDetailParams(jobId: 'job-1'));

    expect(result, Right(expected));
    verify(() => mockRepository.getJobDetail('job-1')).called(1);
  });

  test('RecordJobViewUseCase should return repository result', () async {
    when(
      () => mockRepository.recordJobView(any()),
    ).thenAnswer((_) async => const Right(null));

    final usecase = RecordJobViewUseCase(repository: mockRepository);
    final result = await usecase(const RecordJobViewParams(jobId: 'job-1'));

    expect(result, const Right(null));
    verify(() => mockRepository.recordJobView('job-1')).called(1);
  });

  test('CreateJobUseCase should pass payload to repository', () async {
    final expected = buildJobEntity();
    when(
      () => mockRepository.createJob(any()),
    ).thenAnswer((_) async => Right(expected));

    final usecase = CreateJobUseCase(repository: mockRepository);
    final result = await usecase(
      const CreateJobParams(data: {'title': 'AI Engineer'}),
    );

    expect(result, Right(expected));
    verify(() => mockRepository.createJob({'title': 'AI Engineer'})).called(1);
  });

  test('UpdateJobUseCase should pass payload to repository', () async {
    final expected = buildJobEntity();
    when(
      () => mockRepository.updateJob(any(), any()),
    ).thenAnswer((_) async => Right(expected));

    final usecase = UpdateJobUseCase(repository: mockRepository);
    final result = await usecase(
      const UpdateJobParams(jobId: 'job-1', data: {'title': 'Updated'}),
    );

    expect(result, Right(expected));
    verify(
      () => mockRepository.updateJob('job-1', {'title': 'Updated'}),
    ).called(1);
  });

  test('DeleteJobUseCase should return repository failure', () async {
    const failure = ApiFailure(message: 'Delete failed');
    when(
      () => mockRepository.deleteJob(any()),
    ).thenAnswer((_) async => const Left(failure));

    final usecase = DeleteJobUseCase(repository: mockRepository);
    final result = await usecase(const DeleteJobParams(jobId: 'job-1'));

    expect(result, const Left(failure));
  });

  test('GetJobMetricsUseCase should pass id to repository', () async {
    final expected = buildJobMetricsEntity();
    when(
      () => mockRepository.getJobMetrics(any()),
    ).thenAnswer((_) async => Right(expected));

    final usecase = GetJobMetricsUseCase(repository: mockRepository);
    final result = await usecase(const GetJobMetricsParams(jobId: 'job-1'));

    expect(result, Right(expected));
    verify(() => mockRepository.getJobMetrics('job-1')).called(1);
  });
}
