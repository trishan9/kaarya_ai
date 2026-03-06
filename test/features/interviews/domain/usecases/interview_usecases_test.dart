import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/interviews/data/repositories/interview_repository.dart';
import 'package:kaarya/features/interviews/domain/repositories/interview_repository.dart';
import 'package:kaarya/features/interviews/domain/usecases/complete_session_usecase.dart';
import 'package:kaarya/features/interviews/domain/usecases/create_interview_usecase.dart';
import 'package:kaarya/features/interviews/domain/usecases/delete_interview_usecase.dart';
import 'package:kaarya/features/interviews/domain/usecases/get_interviews_section_usecase.dart';
import 'package:kaarya/features/interviews/domain/usecases/get_interview_analytics_usecase.dart';
import 'package:kaarya/features/interviews/domain/usecases/get_interview_by_id_usecase.dart';
import 'package:kaarya/features/interviews/domain/usecases/get_interview_feedback_usecase.dart';
import 'package:kaarya/features/interviews/domain/usecases/list_my_sessions_usecase.dart';
import 'package:kaarya/features/interviews/domain/usecases/set_interview_saved_usecase.dart';
import 'package:kaarya/features/interviews/domain/usecases/start_interview_session_usecase.dart';
import 'package:kaarya/features/interviews/domain/usecases/update_interview_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_fixtures.dart';

class MockInterviewRepository extends Mock implements IInterviewRepository {}

void main() {
  late MockInterviewRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockInterviewRepository();
    container = ProviderContainer(
      overrides: [
        interviewRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('interview usecase providers should resolve', () {
    expect(
      container.read(getInterviewsSectionUseCaseProvider),
      isA<GetInterviewsSectionUseCase>(),
    );
    expect(container.read(getInterviewByIdUseCaseProvider), isA<GetInterviewByIdUseCase>());
    expect(container.read(createInterviewUseCaseProvider), isA<CreateInterviewUseCase>());
    expect(container.read(updateInterviewUseCaseProvider), isA<UpdateInterviewUseCase>());
    expect(container.read(deleteInterviewUseCaseProvider), isA<DeleteInterviewUseCase>());
    expect(
      container.read(startInterviewSessionUseCaseProvider),
      isA<StartInterviewSessionUseCase>(),
    );
    expect(container.read(completeSessionUseCaseProvider), isA<CompleteSessionUseCase>());
    expect(container.read(listMySessionsUseCaseProvider), isA<ListMySessionsUseCase>());
    expect(
      container.read(getInterviewFeedbackUseCaseProvider),
      isA<GetInterviewFeedbackUseCase>(),
    );
    expect(
      container.read(getInterviewAnalyticsUseCaseProvider),
      isA<GetInterviewAnalyticsUseCase>(),
    );
    expect(container.read(setInterviewSavedUseCaseProvider), isA<SetInterviewSavedUseCase>());
  });

  test('GetInterviewsSectionUseCase should pass filters to repository', () async {
    final expected = buildInterviewsSectionEntity();
    when(
      () => mockRepository.getInterviewsSection(
        searchQuery: any(named: 'searchQuery'),
        interviewType: any(named: 'interviewType'),
        status: any(named: 'status'),
        sortBy: any(named: 'sortBy'),
        attemptFilter: any(named: 'attemptFilter'),
      ),
    ).thenAnswer((_) async => Right(expected));

    final usecase = GetInterviewsSectionUseCase(repository: mockRepository);
    final result = await usecase(
      const GetInterviewsSectionUseCaseParams(
        searchQuery: 'flutter',
        interviewType: 'technical',
        status: 'published',
        sortBy: 'recent',
        attemptFilter: 'all',
      ),
    );

    expect(result, Right(expected));
    verify(
      () => mockRepository.getInterviewsSection(
        searchQuery: 'flutter',
        interviewType: 'technical',
        status: 'published',
        sortBy: 'recent',
        attemptFilter: 'all',
      ),
    ).called(1);
  });

  test('GetInterviewByIdUseCase should pass interview id', () async {
    final expected = buildInterviewEntity();
    when(() => mockRepository.getInterviewById(any())).thenAnswer(
      (_) async => Right(expected),
    );

    final usecase = GetInterviewByIdUseCase(repository: mockRepository);
    final result = await usecase(
      const GetInterviewByIdUseCaseParams(id: 'interview-1'),
    );

    expect(result, Right(expected));
    verify(() => mockRepository.getInterviewById('interview-1')).called(1);
  });

  test('CreateInterviewUseCase should pass creation payload', () async {
    final expected = buildInterviewEntity();
    when(
      () => mockRepository.createInterview(
        title: any(named: 'title'),
        description: any(named: 'description'),
        interviewType: any(named: 'interviewType'),
        role: any(named: 'role'),
        level: any(named: 'level'),
        techStack: any(named: 'techStack'),
        questionCount: any(named: 'questionCount'),
        durationMinutes: any(named: 'durationMinutes'),
        visibility: any(named: 'visibility'),
        status: any(named: 'status'),
        tags: any(named: 'tags'),
        instructions: any(named: 'instructions'),
        generateQuestions: any(named: 'generateQuestions'),
        companyId: any(named: 'companyId'),
        collegeId: any(named: 'collegeId'),
      ),
    ).thenAnswer((_) async => Right(expected));

    final usecase = CreateInterviewUseCase(repository: mockRepository);
    final result = await usecase(
      const CreateInterviewUseCaseParams(
        title: 'Flutter Mock',
        description: 'Practice round',
        interviewType: 'technical',
        role: 'Flutter Developer',
        level: 'Mid',
        techStack: ['Flutter', 'Dart'],
        questionCount: 5,
        durationMinutes: 30,
        visibility: 'private',
        status: 'draft',
        tags: ['mobile'],
        instructions: 'Ask concise questions',
        generateQuestions: true,
        companyId: 'company-1',
      ),
    );

    expect(result, Right(expected));
    verify(
      () => mockRepository.createInterview(
        title: 'Flutter Mock',
        description: 'Practice round',
        interviewType: 'technical',
        role: 'Flutter Developer',
        level: 'Mid',
        techStack: ['Flutter', 'Dart'],
        questionCount: 5,
        durationMinutes: 30,
        visibility: 'private',
        status: 'draft',
        tags: ['mobile'],
        instructions: 'Ask concise questions',
        generateQuestions: true,
        companyId: 'company-1',
        collegeId: null,
      ),
    ).called(1);
  });

  test('UpdateInterviewUseCase should pass update payload', () async {
    final expected = buildInterviewEntity();
    when(
      () => mockRepository.updateInterview(
        id: any(named: 'id'),
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async => Right(expected));

    final usecase = UpdateInterviewUseCase(repository: mockRepository);
    final result = await usecase(
      const UpdateInterviewUseCaseParams(
        id: 'interview-1',
        data: {'status': 'published'},
      ),
    );

    expect(result, Right(expected));
    verify(
      () => mockRepository.updateInterview(
        id: 'interview-1',
        data: {'status': 'published'},
      ),
    ).called(1);
  });

  test('DeleteInterviewUseCase should return repository result', () async {
    when(() => mockRepository.deleteInterview(any())).thenAnswer(
      (_) async => const Right(true),
    );

    final usecase = DeleteInterviewUseCase(repository: mockRepository);
    final result = await usecase(
      const DeleteInterviewUseCaseParams(id: 'interview-1'),
    );

    expect(result, const Right(true));
    verify(() => mockRepository.deleteInterview('interview-1')).called(1);
  });

  test('StartInterviewSessionUseCase should call repository', () async {
    final expected = buildInterviewSessionStartEntity();
    when(() => mockRepository.startInterviewSession(any())).thenAnswer(
      (_) async => Right(expected),
    );

    final usecase = StartInterviewSessionUseCase(repository: mockRepository);
    final result = await usecase(
      const StartInterviewSessionUseCaseParams(interviewId: 'interview-1'),
    );

    expect(result, Right(expected));
    verify(() => mockRepository.startInterviewSession('interview-1')).called(1);
  });

  test('CompleteSessionUseCase should pass finalize payload', () async {
    when(
      () => mockRepository.completeSession(
        interviewId: any(named: 'interviewId'),
        sessionId: any(named: 'sessionId'),
        status: any(named: 'status'),
        transcript: any(named: 'transcript'),
        recordingUrl: any(named: 'recordingUrl'),
        durationSeconds: any(named: 'durationSeconds'),
        vapiCallId: any(named: 'vapiCallId'),
        generateEvaluation: any(named: 'generateEvaluation'),
      ),
    ).thenAnswer((_) async => const Right(true));

    final usecase = CompleteSessionUseCase(repository: mockRepository);
    final result = await usecase(
      const CompleteSessionUseCaseParams(
        interviewId: 'interview-1',
        sessionId: 'session-1',
        status: 'completed',
        transcript: [
          {'role': 'assistant', 'content': 'Question'}
        ],
        recordingUrl: 'https://example.com/recording.mp3',
        durationSeconds: 600,
        vapiCallId: 'call-1',
        generateEvaluation: true,
      ),
    );

    expect(result, const Right(true));
    verify(
      () => mockRepository.completeSession(
        interviewId: 'interview-1',
        sessionId: 'session-1',
        status: 'completed',
        transcript: [
          {'role': 'assistant', 'content': 'Question'}
        ],
        recordingUrl: 'https://example.com/recording.mp3',
        durationSeconds: 600,
        vapiCallId: 'call-1',
        generateEvaluation: true,
      ),
    ).called(1);
  });

  test('ListMySessionsUseCase should pass interview id', () async {
    final expected = [buildInterviewSessionEntity()];
    when(() => mockRepository.listMySessions(any())).thenAnswer(
      (_) async => Right(expected),
    );

    final usecase = ListMySessionsUseCase(repository: mockRepository);
    final result = await usecase(
      const ListMySessionsUseCaseParams(interviewId: 'interview-1'),
    );

    expect(result, Right(expected));
    verify(() => mockRepository.listMySessions('interview-1')).called(1);
  });

  test('GetInterviewFeedbackUseCase should pass session id', () async {
    final expected = buildInterviewFeedbackEntity();
    when(() => mockRepository.getInterviewFeedback(any())).thenAnswer(
      (_) async => Right(expected),
    );

    final usecase = GetInterviewFeedbackUseCase(repository: mockRepository);
    final result = await usecase(
      const GetInterviewFeedbackUseCaseParams(sessionId: 'session-1'),
    );

    expect(result, Right(expected));
    verify(() => mockRepository.getInterviewFeedback('session-1')).called(1);
  });

  test('GetInterviewAnalyticsUseCase should pass interview id', () async {
    final expected = buildInterviewAnalyticsEntity();
    when(() => mockRepository.getInterviewAnalytics(any())).thenAnswer(
      (_) async => Right(expected),
    );

    final usecase = GetInterviewAnalyticsUseCase(repository: mockRepository);
    final result = await usecase(
      const GetInterviewAnalyticsUseCaseParams(interviewId: 'interview-1'),
    );

    expect(result, Right(expected));
    verify(() => mockRepository.getInterviewAnalytics('interview-1')).called(1);
  });

  test('SetInterviewSavedUseCase should pass save flag', () async {
    when(
      () => mockRepository.setInterviewSaved(
        interviewId: any(named: 'interviewId'),
        isSaved: any(named: 'isSaved'),
      ),
    ).thenAnswer((_) async => const Right(true));

    final usecase = SetInterviewSavedUseCase(repository: mockRepository);
    final result = await usecase(
      const SetInterviewSavedUseCaseParams(
        interviewId: 'interview-1',
        isSaved: true,
      ),
    );

    expect(result, const Right(true));
    verify(
      () => mockRepository.setInterviewSaved(
        interviewId: 'interview-1',
        isSaved: true,
      ),
    ).called(1);
  });
}
