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
import 'package:kaarya/features/applications/presentation/state/application_state.dart';
import 'package:kaarya/features/applications/presentation/view_model/application_view_model.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_fixtures.dart';

class MockApplicationRepository extends Mock implements IApplicationRepository {}

class MockGetMyApplicationsUseCase extends Mock implements GetMyApplicationsUseCase {}

class MockGetApplicationsSummaryUseCase extends Mock
    implements GetApplicationsSummaryUseCase {}

class MockGetApplicationForJobUseCase extends Mock
    implements GetApplicationForJobUseCase {}

class MockApplyToJobUseCase extends Mock implements ApplyToJobUseCase {}

class MockGetJobApplicationsUseCase extends Mock
    implements GetJobApplicationsUseCase {}

class MockUpdateApplicationUseCase extends Mock
    implements UpdateApplicationUseCase {}

class MockListMyResumesUseCase extends Mock implements ListMyResumesUseCase {}

class MockUploadResumeUseCase extends Mock implements UploadResumeUseCase {}

class MockDeleteResumeUseCase extends Mock implements DeleteResumeUseCase {}

class MockUpdateResumeActivityUseCase extends Mock
    implements UpdateResumeActivityUseCase {}

void main() {
  late MockApplicationRepository mockApplicationRepository;
  late MockGetMyApplicationsUseCase mockGetMyApplicationsUseCase;
  late MockGetApplicationsSummaryUseCase mockGetApplicationsSummaryUseCase;
  late MockGetApplicationForJobUseCase mockGetApplicationForJobUseCase;
  late MockApplyToJobUseCase mockApplyToJobUseCase;
  late MockGetJobApplicationsUseCase mockGetJobApplicationsUseCase;
  late MockUpdateApplicationUseCase mockUpdateApplicationUseCase;
  late MockListMyResumesUseCase mockListMyResumesUseCase;
  late MockUploadResumeUseCase mockUploadResumeUseCase;
  late MockDeleteResumeUseCase mockDeleteResumeUseCase;
  late MockUpdateResumeActivityUseCase mockUpdateResumeActivityUseCase;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(const GetMyApplicationsUseCaseParams());
    registerFallbackValue(const GetApplicationsSummaryUseCaseParams());
    registerFallbackValue(
      const GetApplicationForJobUseCaseParams(jobId: 'job-1'),
    );
    registerFallbackValue(const ApplyToJobUseCaseParams(jobId: 'job-1'));
    registerFallbackValue(
      const GetJobApplicationsUseCaseParams(jobId: 'job-1'),
    );
    registerFallbackValue(
      const UpdateApplicationUseCaseParams(
        jobId: 'job-1',
        applicationId: 'app-1',
      ),
    );
    registerFallbackValue(const ListMyResumesUseCaseParams());
    registerFallbackValue(
      const UploadResumeUseCaseParams(filePath: '/tmp/resume.pdf'),
    );
    registerFallbackValue(
      const DeleteResumeUseCaseParams(resumeId: 'resume-1'),
    );
    registerFallbackValue(
      const UpdateResumeActivityUseCaseParams(
        jobId: 'job-1',
        applicationId: 'app-1',
        action: 'opened',
      ),
    );
  });

  setUp(() {
    mockApplicationRepository = MockApplicationRepository();
    mockGetMyApplicationsUseCase = MockGetMyApplicationsUseCase();
    mockGetApplicationsSummaryUseCase = MockGetApplicationsSummaryUseCase();
    mockGetApplicationForJobUseCase = MockGetApplicationForJobUseCase();
    mockApplyToJobUseCase = MockApplyToJobUseCase();
    mockGetJobApplicationsUseCase = MockGetJobApplicationsUseCase();
    mockUpdateApplicationUseCase = MockUpdateApplicationUseCase();
    mockListMyResumesUseCase = MockListMyResumesUseCase();
    mockUploadResumeUseCase = MockUploadResumeUseCase();
    mockDeleteResumeUseCase = MockDeleteResumeUseCase();
    mockUpdateResumeActivityUseCase = MockUpdateResumeActivityUseCase();

    container = ProviderContainer(
      overrides: [
        applicationRepositoryProvider.overrideWithValue(
          mockApplicationRepository,
        ),
        getMyApplicationsUseCaseProvider.overrideWithValue(
          mockGetMyApplicationsUseCase,
        ),
        getApplicationsSummaryUseCaseProvider.overrideWithValue(
          mockGetApplicationsSummaryUseCase,
        ),
        getApplicationForJobUseCaseProvider.overrideWithValue(
          mockGetApplicationForJobUseCase,
        ),
        applyToJobUseCaseProvider.overrideWithValue(mockApplyToJobUseCase),
        getJobApplicationsUseCaseProvider.overrideWithValue(
          mockGetJobApplicationsUseCase,
        ),
        updateApplicationUseCaseProvider.overrideWithValue(
          mockUpdateApplicationUseCase,
        ),
        listMyResumesUseCaseProvider.overrideWithValue(mockListMyResumesUseCase),
        uploadResumeUseCaseProvider.overrideWithValue(mockUploadResumeUseCase),
        deleteResumeUseCaseProvider.overrideWithValue(mockDeleteResumeUseCase),
        updateResumeActivityUseCaseProvider.overrideWithValue(
          mockUpdateResumeActivityUseCase,
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('ApplicationViewModel should load applications and summary', () async {
    when(
      () => mockGetMyApplicationsUseCase(any()),
    ).thenAnswer((_) async => Right(buildApplicationsListEntity()));
    when(
      () => mockGetApplicationsSummaryUseCase(any()),
    ).thenAnswer((_) async => Right(buildApplicationSummaryEntity()));

    final viewModel = container.read(applicationViewModelProvider.notifier);
    await viewModel.loadMyApplications();
    await viewModel.loadApplicationsSummary();

    final state = container.read(applicationViewModelProvider);
    expect(state.applicationsStatus, ApplicationLoadStatus.loaded);
    expect(state.summaryStatus, ApplicationLoadStatus.loaded);
  });

  test('ApplicationViewModel should load application detail and job applicants', () async {
    when(
      () => mockGetApplicationForJobUseCase(any()),
    ).thenAnswer((_) async => Right(buildApplicationEntity()));
    when(
      () => mockApplicationRepository.getJobApplicants(
        jobId: any(named: 'jobId'),
        page: any(named: 'page'),
        size: any(named: 'size'),
        status: any(named: 'status'),
      ),
    ).thenAnswer((_) async => Right(buildJobApplicantsListEntity()));

    final viewModel = container.read(applicationViewModelProvider.notifier);
    await viewModel.loadApplicationForJob(jobId: 'job-1');
    await viewModel.loadJobApplicants(jobId: 'job-1');

    final state = container.read(applicationViewModelProvider);
    expect(state.applicationForJobStatus, ApplicationLoadStatus.loaded);
    expect(state.jobApplicantsStatus, ApplicationLoadStatus.loaded);
  });

  test('ApplicationViewModel should update resume list on upload and delete', () async {
    final resume = buildResumeEntity();
    when(
      () => mockListMyResumesUseCase(any()),
    ).thenAnswer((_) async => Right([resume]));
    when(
      () => mockUploadResumeUseCase(any()),
    ).thenAnswer((_) async => Right(buildResumeEntity(id: 'resume-2')));
    when(
      () => mockDeleteResumeUseCase(any()),
    ).thenAnswer((_) async => const Right(true));

    final viewModel = container.read(applicationViewModelProvider.notifier);
    await viewModel.loadMyResumes();
    final uploadResult = await viewModel.uploadResume(filePath: '/tmp/resume.pdf');
    final deleteResult = await viewModel.deleteResume(resumeId: 'resume-1');

    expect(uploadResult.$2, isNull);
    expect(deleteResult, isNull);
    expect(container.read(applicationViewModelProvider).resumesData?.length, 1);
  });

  test('ApplicationViewModel should return failures for apply and update actions', () async {
    const failure = ApiFailure(message: 'Action failed');
    when(
      () => mockApplyToJobUseCase(any()),
    ).thenAnswer((_) async => const Left(failure));
    when(
      () => mockUpdateApplicationUseCase(any()),
    ).thenAnswer((_) async => const Left(failure));

    final viewModel = container.read(applicationViewModelProvider.notifier);
    final applyFailure = await viewModel.applyToJob('job-1');
    final updateFailure = await viewModel.updateApplication(
      jobId: 'job-1',
      applicationId: 'app-1',
    );

    expect(applyFailure, failure);
    expect(updateFailure, failure);
    expect(
      container.read(applicationViewModelProvider).updateApplicationStatus,
      ApplicationLoadStatus.error,
    );
  });

  test('ApplicationViewModel should reset state', () {
    final viewModel = container.read(applicationViewModelProvider.notifier);
    viewModel.resetState();

    expect(
      container.read(applicationViewModelProvider),
      const ApplicationState(),
    );
  });
}
