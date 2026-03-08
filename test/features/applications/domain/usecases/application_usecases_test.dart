import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/applications/data/repositories/application_repository.dart';
import 'package:kaarya/features/applications/domain/repositories/application_repository.dart';
import 'package:kaarya/features/applications/domain/usecases/apply_to_job_usecase.dart';
import 'package:kaarya/features/applications/domain/usecases/delete_resume_usecase.dart';
import 'package:kaarya/features/applications/domain/usecases/get_application_for_job_usecase.dart';
import 'package:kaarya/features/applications/domain/usecases/get_applications_summary_usecase.dart';
import 'package:kaarya/features/applications/domain/usecases/get_job_applications_usecase.dart';
import 'package:kaarya/features/applications/domain/usecases/get_my_applications_usecase.dart';
import 'package:kaarya/features/applications/domain/usecases/list_my_resumes_usecase.dart';
import 'package:kaarya/features/applications/domain/usecases/update_application_usecase.dart';
import 'package:kaarya/features/applications/domain/usecases/update_resume_activity_usecase.dart';
import 'package:kaarya/features/applications/domain/usecases/upload_resume_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_fixtures.dart';

class MockApplicationRepository extends Mock
    implements IApplicationRepository {}

void main() {
  late MockApplicationRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockApplicationRepository();
    container = ProviderContainer(
      overrides: [
        applicationRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('application usecase providers should resolve', () {
    expect(
      container.read(getMyApplicationsUseCaseProvider),
      isA<GetMyApplicationsUseCase>(),
    );
    expect(
      container.read(getApplicationsSummaryUseCaseProvider),
      isA<GetApplicationsSummaryUseCase>(),
    );
    expect(
      container.read(getApplicationForJobUseCaseProvider),
      isA<GetApplicationForJobUseCase>(),
    );
    expect(container.read(applyToJobUseCaseProvider), isA<ApplyToJobUseCase>());
    expect(
      container.read(getJobApplicationsUseCaseProvider),
      isA<GetJobApplicationsUseCase>(),
    );
    expect(
      container.read(updateApplicationUseCaseProvider),
      isA<UpdateApplicationUseCase>(),
    );
    expect(
      container.read(listMyResumesUseCaseProvider),
      isA<ListMyResumesUseCase>(),
    );
    expect(
      container.read(uploadResumeUseCaseProvider),
      isA<UploadResumeUseCase>(),
    );
    expect(
      container.read(deleteResumeUseCaseProvider),
      isA<DeleteResumeUseCase>(),
    );
    expect(
      container.read(updateResumeActivityUseCaseProvider),
      isA<UpdateResumeActivityUseCase>(),
    );
  });

  test(
    'GetMyApplicationsUseCase should pass paging filters to repository',
    () async {
      final expected = buildApplicationsListEntity();
      when(
        () => mockRepository.getMyApplications(
          page: any(named: 'page'),
          size: any(named: 'size'),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) async => Right(expected));

      final usecase = GetMyApplicationsUseCase(repository: mockRepository);
      const params = GetMyApplicationsUseCaseParams(
        page: 2,
        size: 10,
        status: 'reviewing',
      );

      final result = await usecase(params);

      expect(result, Right(expected));
      verify(
        () => mockRepository.getMyApplications(
          page: 2,
          size: 10,
          status: 'reviewing',
        ),
      ).called(1);
    },
  );

  test(
    'GetApplicationsSummaryUseCase should pass summary filters to repository',
    () async {
      final expected = buildApplicationSummaryEntity();
      when(
        () => mockRepository.getApplicationsSummary(
          month: any(named: 'month'),
          statuses: any(named: 'statuses'),
        ),
      ).thenAnswer((_) async => Right(expected));

      final usecase = GetApplicationsSummaryUseCase(repository: mockRepository);
      const params = GetApplicationsSummaryUseCaseParams(
        month: '2026-03',
        statuses: 'applied,reviewing',
      );

      final result = await usecase(params);

      expect(result, Right(expected));
      verify(
        () => mockRepository.getApplicationsSummary(
          month: '2026-03',
          statuses: 'applied,reviewing',
        ),
      ).called(1);
    },
  );

  test(
    'GetApplicationForJobUseCase should pass job id to repository',
    () async {
      final expected = buildApplicationEntity();
      when(
        () => mockRepository.getApplicationForJob(jobId: any(named: 'jobId')),
      ).thenAnswer((_) async => Right(expected));

      final usecase = GetApplicationForJobUseCase(repository: mockRepository);
      final result = await usecase(
        const GetApplicationForJobUseCaseParams(jobId: 'job-1'),
      );

      expect(result, Right(expected));
      verify(
        () => mockRepository.getApplicationForJob(jobId: 'job-1'),
      ).called(1);
    },
  );

  test(
    'ApplyToJobUseCase should pass application payload to repository',
    () async {
      when(
        () => mockRepository.applyToJob(
          jobId: any(named: 'jobId'),
          resumeId: any(named: 'resumeId'),
          resumeFilePath: any(named: 'resumeFilePath'),
          resumeBytes: any(named: 'resumeBytes'),
          resumeFilename: any(named: 'resumeFilename'),
          coverLetter: any(named: 'coverLetter'),
          portfolioLinks: any(named: 'portfolioLinks'),
        ),
      ).thenAnswer((_) async => const Right(true));

      final usecase = ApplyToJobUseCase(repository: mockRepository);
      final result = await usecase(
        const ApplyToJobUseCaseParams(
          jobId: 'job-1',
          resumeId: 'resume-1',
          resumeFilePath: '/tmp/resume.pdf',
          resumeBytes: [1, 2, 3],
          resumeFilename: 'resume.pdf',
          coverLetter: 'Please consider me',
          portfolioLinks: ['https://portfolio.example.com'],
        ),
      );

      expect(result, const Right(true));
      verify(
        () => mockRepository.applyToJob(
          jobId: 'job-1',
          resumeId: 'resume-1',
          resumeFilePath: '/tmp/resume.pdf',
          resumeBytes: [1, 2, 3],
          resumeFilename: 'resume.pdf',
          coverLetter: 'Please consider me',
          portfolioLinks: ['https://portfolio.example.com'],
        ),
      ).called(1);
    },
  );

  test(
    'GetJobApplicationsUseCase should pass applicant filters to repository',
    () async {
      final expected = buildApplicationsListEntity();
      when(
        () => mockRepository.getJobApplications(
          jobId: any(named: 'jobId'),
          page: any(named: 'page'),
          size: any(named: 'size'),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) async => Right(expected));

      final usecase = GetJobApplicationsUseCase(repository: mockRepository);
      final result = await usecase(
        const GetJobApplicationsUseCaseParams(
          jobId: 'job-1',
          page: 3,
          size: 15,
          status: 'shortlisted',
        ),
      );

      expect(result, Right(expected));
      verify(
        () => mockRepository.getJobApplications(
          jobId: 'job-1',
          page: 3,
          size: 15,
          status: 'shortlisted',
        ),
      ).called(1);
    },
  );

  test(
    'UpdateApplicationUseCase should pass update payload to repository',
    () async {
      final scheduledAt = DateTime(2026, 3, 8, 10);
      when(
        () => mockRepository.updateApplication(
          jobId: any(named: 'jobId'),
          applicationId: any(named: 'applicationId'),
          status: any(named: 'status'),
          interviewScheduledAt: any(named: 'interviewScheduledAt'),
          interviewNote: any(named: 'interviewNote'),
        ),
      ).thenAnswer((_) async => const Right(true));

      final usecase = UpdateApplicationUseCase(repository: mockRepository);
      final result = await usecase(
        UpdateApplicationUseCaseParams(
          jobId: 'job-1',
          applicationId: 'app-1',
          status: 'interview',
          interviewScheduledAt: scheduledAt,
          interviewNote: 'Bring portfolio',
        ),
      );

      expect(result, const Right(true));
      verify(
        () => mockRepository.updateApplication(
          jobId: 'job-1',
          applicationId: 'app-1',
          status: 'interview',
          interviewScheduledAt: scheduledAt,
          interviewNote: 'Bring portfolio',
        ),
      ).called(1);
    },
  );

  test(
    'ListMyResumesUseCase should pass paging values to repository',
    () async {
      final expected = [buildResumeEntity()];
      when(
        () => mockRepository.listMyResumes(
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenAnswer((_) async => Right(expected));

      final usecase = ListMyResumesUseCase(repository: mockRepository);
      final result = await usecase(
        const ListMyResumesUseCaseParams(page: 2, size: 5),
      );

      expect(result, Right(expected));
      verify(() => mockRepository.listMyResumes(page: 2, size: 5)).called(1);
    },
  );

  test('UploadResumeUseCase should pass file path to repository', () async {
    final expected = buildResumeEntity();
    when(
      () => mockRepository.uploadResume(filePath: any(named: 'filePath')),
    ).thenAnswer((_) async => Right(expected));

    final usecase = UploadResumeUseCase(repository: mockRepository);
    final result = await usecase(
      const UploadResumeUseCaseParams(filePath: '/tmp/resume.pdf'),
    );

    expect(result, Right(expected));
    verify(
      () => mockRepository.uploadResume(filePath: '/tmp/resume.pdf'),
    ).called(1);
  });

  test('DeleteResumeUseCase should return repository failure', () async {
    const failure = ApiFailure(message: 'Delete failed');
    when(
      () => mockRepository.deleteResume(resumeId: any(named: 'resumeId')),
    ).thenAnswer((_) async => const Left(failure));

    final usecase = DeleteResumeUseCase(repository: mockRepository);
    final result = await usecase(
      const DeleteResumeUseCaseParams(resumeId: 'resume-1'),
    );

    expect(result, const Left(failure));
    verify(() => mockRepository.deleteResume(resumeId: 'resume-1')).called(1);
  });

  test('UpdateResumeActivityUseCase should call repository', () async {
    when(
      () => mockRepository.updateResumeActivity(
        jobId: any(named: 'jobId'),
        applicationId: any(named: 'applicationId'),
        action: any(named: 'action'),
      ),
    ).thenAnswer((_) async => const Right(true));

    final usecase = UpdateResumeActivityUseCase(repository: mockRepository);
    final result = await usecase(
      const UpdateResumeActivityUseCaseParams(
        jobId: 'job-1',
        applicationId: 'app-1',
        action: 'opened',
      ),
    );

    expect(result, const Right(true));
    verify(
      () => mockRepository.updateResumeActivity(
        jobId: 'job-1',
        applicationId: 'app-1',
        action: 'opened',
      ),
    ).called(1);
  });
}
