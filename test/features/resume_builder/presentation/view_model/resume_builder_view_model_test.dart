import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/resume_builder/domain/entities/resume_draft_entity.dart';
import 'package:kaarya/features/resume_builder/domain/usecases/ats_scan_usecase.dart';
import 'package:kaarya/features/resume_builder/domain/usecases/create_draft_usecase.dart';
import 'package:kaarya/features/resume_builder/domain/usecases/delete_draft_usecase.dart';
import 'package:kaarya/features/resume_builder/domain/usecases/generate_ai_suggestions_usecase.dart';
import 'package:kaarya/features/resume_builder/domain/usecases/generate_ai_summary_usecase.dart';
import 'package:kaarya/features/resume_builder/domain/usecases/generate_experience_bullets_usecase.dart';
import 'package:kaarya/features/resume_builder/domain/usecases/generate_pdf_usecase.dart';
import 'package:kaarya/features/resume_builder/domain/usecases/get_draft_by_id_usecase.dart';
import 'package:kaarya/features/resume_builder/domain/usecases/list_drafts_usecase.dart';
import 'package:kaarya/features/resume_builder/domain/usecases/save_as_resume_usecase.dart';
import 'package:kaarya/features/resume_builder/domain/usecases/update_draft_usecase.dart';
import 'package:kaarya/features/resume_builder/presentation/state/resume_builder_state.dart';
import 'package:kaarya/features/resume_builder/presentation/view_model/resume_builder_view_model.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_fixtures.dart';

class MockCreateDraftUseCase extends Mock implements CreateDraftUseCase {}

class MockListDraftsUseCase extends Mock implements ListDraftsUseCase {}

class MockGetDraftByIdUseCase extends Mock implements GetDraftByIdUseCase {}

class MockUpdateDraftUseCase extends Mock implements UpdateDraftUseCase {}

class MockDeleteDraftUseCase extends Mock implements DeleteDraftUseCase {}

class MockGeneratePdfUseCase extends Mock implements GeneratePdfUseCase {}

class MockSaveAsResumeUseCase extends Mock implements SaveAsResumeUseCase {}

class MockGenerateAiSummaryUseCase extends Mock
    implements GenerateAiSummaryUseCase {}

class MockGenerateExperienceBulletsUseCase extends Mock
    implements GenerateExperienceBulletsUseCase {}

class MockGenerateAiSuggestionsUseCase extends Mock
    implements GenerateAiSuggestionsUseCase {}

class MockAtsScanUseCase extends Mock implements AtsScanUseCase {}

void main() {
  late MockCreateDraftUseCase mockCreateDraftUseCase;
  late MockListDraftsUseCase mockListDraftsUseCase;
  late MockGetDraftByIdUseCase mockGetDraftByIdUseCase;
  late MockUpdateDraftUseCase mockUpdateDraftUseCase;
  late MockDeleteDraftUseCase mockDeleteDraftUseCase;
  late MockGeneratePdfUseCase mockGeneratePdfUseCase;
  late MockSaveAsResumeUseCase mockSaveAsResumeUseCase;
  late MockGenerateAiSummaryUseCase mockGenerateAiSummaryUseCase;
  late MockGenerateExperienceBulletsUseCase
  mockGenerateExperienceBulletsUseCase;
  late MockGenerateAiSuggestionsUseCase mockGenerateAiSuggestionsUseCase;
  late MockAtsScanUseCase mockAtsScanUseCase;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(
      const CreateDraftUseCaseParams(title: 'Resume', template: 'modern'),
    );
    registerFallbackValue(const ListDraftsUseCaseParams());
    registerFallbackValue(const GetDraftByIdUseCaseParams(draftId: 'draft-1'));
    registerFallbackValue(
      const UpdateDraftUseCaseParams(
        draftId: 'draft-1',
        fields: {'title': 'Updated Resume'},
      ),
    );
    registerFallbackValue(const DeleteDraftUseCaseParams(draftId: 'draft-1'));
    registerFallbackValue(const GeneratePdfUseCaseParams(draftId: 'draft-1'));
    registerFallbackValue(const SaveAsResumeUseCaseParams(draftId: 'draft-1'));
    registerFallbackValue(
      const GenerateAiSummaryUseCaseParams(
        skills: ['Flutter'],
        experience: ['Built apps'],
        targetRole: 'Flutter Developer',
      ),
    );
    registerFallbackValue(
      const GenerateExperienceBulletsUseCaseParams(
        jobTitle: 'Intern',
        responsibilities: 'Build features',
        techStack: ['Flutter'],
      ),
    );
    registerFallbackValue(
      const GenerateAiSuggestionsUseCaseParams(
        step: 'experience',
        resumeData: {'experience': []},
      ),
    );
    registerFallbackValue(
      const AtsScanUseCaseParams(filePath: '/tmp/resume.pdf'),
    );
  });

  setUp(() {
    mockCreateDraftUseCase = MockCreateDraftUseCase();
    mockListDraftsUseCase = MockListDraftsUseCase();
    mockGetDraftByIdUseCase = MockGetDraftByIdUseCase();
    mockUpdateDraftUseCase = MockUpdateDraftUseCase();
    mockDeleteDraftUseCase = MockDeleteDraftUseCase();
    mockGeneratePdfUseCase = MockGeneratePdfUseCase();
    mockSaveAsResumeUseCase = MockSaveAsResumeUseCase();
    mockGenerateAiSummaryUseCase = MockGenerateAiSummaryUseCase();
    mockGenerateExperienceBulletsUseCase =
        MockGenerateExperienceBulletsUseCase();
    mockGenerateAiSuggestionsUseCase = MockGenerateAiSuggestionsUseCase();
    mockAtsScanUseCase = MockAtsScanUseCase();

    container = ProviderContainer(
      overrides: [
        createDraftUseCaseProvider.overrideWithValue(mockCreateDraftUseCase),
        listDraftsUseCaseProvider.overrideWithValue(mockListDraftsUseCase),
        getDraftByIdUseCaseProvider.overrideWithValue(mockGetDraftByIdUseCase),
        updateDraftUseCaseProvider.overrideWithValue(mockUpdateDraftUseCase),
        deleteDraftUseCaseProvider.overrideWithValue(mockDeleteDraftUseCase),
        generatePdfUseCaseProvider.overrideWithValue(mockGeneratePdfUseCase),
        saveAsResumeUseCaseProvider.overrideWithValue(mockSaveAsResumeUseCase),
        generateAiSummaryUseCaseProvider.overrideWithValue(
          mockGenerateAiSummaryUseCase,
        ),
        generateExperienceBulletsUseCaseProvider.overrideWithValue(
          mockGenerateExperienceBulletsUseCase,
        ),
        generateAiSuggestionsUseCaseProvider.overrideWithValue(
          mockGenerateAiSuggestionsUseCase,
        ),
        atsScanUseCaseProvider.overrideWithValue(mockAtsScanUseCase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('ResumeBuilderViewModel should load drafts and draft detail', () async {
    when(
      () => mockListDraftsUseCase(any()),
    ).thenAnswer((_) async => Right(buildResumeDraftsListEntity()));
    when(
      () => mockGetDraftByIdUseCase(any()),
    ).thenAnswer((_) async => Right(buildResumeDraftEntity()));

    final viewModel = container.read(resumeBuilderViewModelProvider.notifier);
    await viewModel.loadDrafts();
    await viewModel.loadDraftDetail('draft-1');

    final state = container.read(resumeBuilderViewModelProvider);
    expect(state.draftsListStatus, ResumeBuilderLoadStatus.loaded);
    expect(state.draftDetailStatus, ResumeBuilderLoadStatus.loaded);
  });

  test(
    'ResumeBuilderViewModel should create and update draft on success',
    () async {
      final draft = buildResumeDraftEntity();
      when(
        () => mockCreateDraftUseCase(any()),
      ).thenAnswer((_) async => Right(draft));
      when(
        () => mockUpdateDraftUseCase(any()),
      ).thenAnswer((_) async => Right(buildResumeDraftEntity(id: 'draft-1')));

      final viewModel = container.read(resumeBuilderViewModelProvider.notifier);
      final createFailure = await viewModel.createDraft(
        title: 'Resume',
        template: 'modern',
      );
      final updateFailure = await viewModel.updateDraft(
        draftId: 'draft-1',
        fields: const {'title': 'Updated Resume'},
      );

      expect(createFailure, isNull);
      expect(updateFailure, isNull);
      expect(
        container.read(resumeBuilderViewModelProvider).createDraftStatus,
        ResumeBuilderLoadStatus.loaded,
      );
    },
  );

  test(
    'ResumeBuilderViewModel should delete, generate pdf, and handle save failure',
    () async {
      when(
        () => mockDeleteDraftUseCase(any()),
      ).thenAnswer((_) async => const Right(true));
      when(() => mockGeneratePdfUseCase(any())).thenAnswer(
        (_) async => const Right(
          GeneratePdfResultEntity(pdfUrl: 'https://example.com/resume.pdf'),
        ),
      );
      when(
        () => mockSaveAsResumeUseCase(any()),
      ).thenAnswer((_) async => const Left(ApiFailure(message: 'Save failed')));

      final viewModel = container.read(resumeBuilderViewModelProvider.notifier);
      final deleteFailure = await viewModel.deleteDraft('draft-1');
      final pdfResult = await viewModel.generatePdf('draft-1');
      final saveFailure = await viewModel.saveAsResume('draft-1');

      expect(deleteFailure, isNull);
      expect(pdfResult.$2, isNull);
      expect(saveFailure, isA<ApiFailure>());
    },
  );

  test(
    'ResumeBuilderViewModel should generate AI helpers and ats scan',
    () async {
      when(() => mockGenerateAiSummaryUseCase(any())).thenAnswer(
        (_) async =>
            const Right(AiSummaryResultEntity(summary: 'Strong engineer')),
      );
      when(() => mockGenerateExperienceBulletsUseCase(any())).thenAnswer(
        (_) async => const Right(
          ExperienceBulletsResultEntity(bullets: ['Built features']),
        ),
      );
      when(() => mockGenerateAiSuggestionsUseCase(any())).thenAnswer(
        (_) async => const Right(
          AiSuggestionsResultEntity(suggestions: ['Add metrics']),
        ),
      );
      when(
        () => mockAtsScanUseCase(any()),
      ).thenAnswer((_) async => Right(buildAtsScanResultEntity()));

      final viewModel = container.read(resumeBuilderViewModelProvider.notifier);
      await viewModel.generateAiSummary(
        skills: const ['Flutter'],
        experience: const ['Built apps'],
        targetRole: 'Flutter Developer',
      );
      await viewModel.generateExperienceBullets(
        jobTitle: 'Intern',
        responsibilities: 'Build features',
        techStack: const ['Flutter'],
      );
      await viewModel.generateAiSuggestions(
        step: 'experience',
        resumeData: const {'experience': []},
      );
      await viewModel.atsScan(filePath: '/tmp/resume.pdf');

      final state = container.read(resumeBuilderViewModelProvider);
      expect(state.aiSummaryStatus, ResumeBuilderLoadStatus.loaded);
      expect(state.experienceBulletsStatus, ResumeBuilderLoadStatus.loaded);
      expect(state.aiSuggestionsStatus, ResumeBuilderLoadStatus.loaded);
      expect(state.atsScanStatus, ResumeBuilderLoadStatus.loaded);
    },
  );

  test('ResumeBuilderViewModel should reset state', () {
    final viewModel = container.read(resumeBuilderViewModelProvider.notifier);
    viewModel.resetState();

    expect(
      container.read(resumeBuilderViewModelProvider),
      const ResumeBuilderState(),
    );
  });
}
