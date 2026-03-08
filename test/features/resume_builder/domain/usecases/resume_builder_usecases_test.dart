import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/resume_builder/data/repositories/resume_builder_repository.dart';
import 'package:kaarya/features/resume_builder/domain/entities/resume_draft_entity.dart';
import 'package:kaarya/features/resume_builder/domain/repositories/resume_builder_repository.dart';
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
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_fixtures.dart';

class MockResumeBuilderRepository extends Mock
    implements IResumeBuilderRepository {}

void main() {
  late MockResumeBuilderRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockResumeBuilderRepository();
    container = ProviderContainer(
      overrides: [
        resumeBuilderRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('resume builder usecase providers should resolve', () {
    expect(
      container.read(createDraftUseCaseProvider),
      isA<CreateDraftUseCase>(),
    );
    expect(container.read(listDraftsUseCaseProvider), isA<ListDraftsUseCase>());
    expect(
      container.read(getDraftByIdUseCaseProvider),
      isA<GetDraftByIdUseCase>(),
    );
    expect(
      container.read(updateDraftUseCaseProvider),
      isA<UpdateDraftUseCase>(),
    );
    expect(
      container.read(deleteDraftUseCaseProvider),
      isA<DeleteDraftUseCase>(),
    );
    expect(
      container.read(generatePdfUseCaseProvider),
      isA<GeneratePdfUseCase>(),
    );
    expect(
      container.read(saveAsResumeUseCaseProvider),
      isA<SaveAsResumeUseCase>(),
    );
    expect(
      container.read(generateAiSummaryUseCaseProvider),
      isA<GenerateAiSummaryUseCase>(),
    );
    expect(
      container.read(generateExperienceBulletsUseCaseProvider),
      isA<GenerateExperienceBulletsUseCase>(),
    );
    expect(
      container.read(generateAiSuggestionsUseCaseProvider),
      isA<GenerateAiSuggestionsUseCase>(),
    );
    expect(container.read(atsScanUseCaseProvider), isA<AtsScanUseCase>());
  });

  test('CreateDraftUseCase should pass creation payload', () async {
    final expected = buildResumeDraftEntity();
    when(
      () => mockRepository.createDraft(
        title: any(named: 'title'),
        template: any(named: 'template'),
        personalInfo: any(named: 'personalInfo'),
        sections: any(named: 'sections'),
      ),
    ).thenAnswer((_) async => Right(expected));

    final usecase = CreateDraftUseCase(repository: mockRepository);
    final result = await usecase(
      const CreateDraftUseCaseParams(
        title: 'SE Resume',
        template: 'modern',
        personalInfo: {'name': 'Test User'},
        sections: {'summary': 'Builder'},
      ),
    );

    expect(result, Right(expected));
    verify(
      () => mockRepository.createDraft(
        title: 'SE Resume',
        template: 'modern',
        personalInfo: {'name': 'Test User'},
        sections: {'summary': 'Builder'},
      ),
    ).called(1);
  });

  test('ListDraftsUseCase should pass paging values', () async {
    final expected = buildResumeDraftsListEntity();
    when(
      () => mockRepository.listDrafts(
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) async => Right(expected));

    final usecase = ListDraftsUseCase(repository: mockRepository);
    final result = await usecase(
      const ListDraftsUseCaseParams(page: 2, size: 5),
    );

    expect(result, Right(expected));
    verify(() => mockRepository.listDrafts(page: 2, size: 5)).called(1);
  });

  test('GetDraftByIdUseCase should pass draft id', () async {
    final expected = buildResumeDraftEntity();
    when(
      () => mockRepository.getDraftById(any()),
    ).thenAnswer((_) async => Right(expected));

    final usecase = GetDraftByIdUseCase(repository: mockRepository);
    final result = await usecase(
      const GetDraftByIdUseCaseParams(draftId: 'draft-1'),
    );

    expect(result, Right(expected));
    verify(() => mockRepository.getDraftById('draft-1')).called(1);
  });

  test('UpdateDraftUseCase should pass update payload', () async {
    final expected = buildResumeDraftEntity();
    when(
      () => mockRepository.updateDraft(
        draftId: any(named: 'draftId'),
        fields: any(named: 'fields'),
      ),
    ).thenAnswer((_) async => Right(expected));

    final usecase = UpdateDraftUseCase(repository: mockRepository);
    final result = await usecase(
      const UpdateDraftUseCaseParams(
        draftId: 'draft-1',
        fields: {'title': 'Updated Resume'},
      ),
    );

    expect(result, Right(expected));
    verify(
      () => mockRepository.updateDraft(
        draftId: 'draft-1',
        fields: {'title': 'Updated Resume'},
      ),
    ).called(1);
  });

  test('DeleteDraftUseCase should return repository result', () async {
    when(
      () => mockRepository.deleteDraft(any()),
    ).thenAnswer((_) async => const Right(true));

    final usecase = DeleteDraftUseCase(repository: mockRepository);
    final result = await usecase(
      const DeleteDraftUseCaseParams(draftId: 'draft-1'),
    );

    expect(result, const Right(true));
    verify(() => mockRepository.deleteDraft('draft-1')).called(1);
  });

  test('GeneratePdfUseCase should pass draft id', () async {
    const expected = GeneratePdfResultEntity(
      pdfUrl: 'https://example.com/resume.pdf',
    );
    when(
      () => mockRepository.generatePdf(any()),
    ).thenAnswer((_) async => const Right(expected));

    final usecase = GeneratePdfUseCase(repository: mockRepository);
    final result = await usecase(
      const GeneratePdfUseCaseParams(draftId: 'draft-1'),
    );

    expect(result, const Right(expected));
    verify(() => mockRepository.generatePdf('draft-1')).called(1);
  });

  test('SaveAsResumeUseCase should return repository failure', () async {
    const failure = ApiFailure(message: 'Save failed');
    when(
      () => mockRepository.saveAsResume(any()),
    ).thenAnswer((_) async => const Left(failure));

    final usecase = SaveAsResumeUseCase(repository: mockRepository);
    final result = await usecase(
      const SaveAsResumeUseCaseParams(draftId: 'draft-1'),
    );

    expect(result, const Left(failure));
    verify(() => mockRepository.saveAsResume('draft-1')).called(1);
  });

  test('GenerateAiSummaryUseCase should pass generation payload', () async {
    const expected = AiSummaryResultEntity(summary: 'Strong engineer');
    when(
      () => mockRepository.generateAiSummary(
        skills: any(named: 'skills'),
        experience: any(named: 'experience'),
        targetRole: any(named: 'targetRole'),
      ),
    ).thenAnswer((_) async => const Right(expected));

    final usecase = GenerateAiSummaryUseCase(repository: mockRepository);
    final result = await usecase(
      const GenerateAiSummaryUseCaseParams(
        skills: ['Flutter'],
        experience: ['Built apps'],
        targetRole: 'Flutter Developer',
      ),
    );

    expect(result, const Right(expected));
    verify(
      () => mockRepository.generateAiSummary(
        skills: ['Flutter'],
        experience: ['Built apps'],
        targetRole: 'Flutter Developer',
      ),
    ).called(1);
  });

  test('GenerateExperienceBulletsUseCase should call repository', () async {
    const expected = ExperienceBulletsResultEntity(
      bullets: ['Improved performance by 20%'],
    );
    when(
      () => mockRepository.generateExperienceBullets(
        jobTitle: any(named: 'jobTitle'),
        responsibilities: any(named: 'responsibilities'),
        techStack: any(named: 'techStack'),
      ),
    ).thenAnswer((_) async => const Right(expected));

    final usecase = GenerateExperienceBulletsUseCase(
      repository: mockRepository,
    );
    final result = await usecase(
      const GenerateExperienceBulletsUseCaseParams(
        jobTitle: 'Intern',
        responsibilities: 'Build features',
        techStack: ['Flutter', 'Firebase'],
      ),
    );

    expect(result, const Right(expected));
    verify(
      () => mockRepository.generateExperienceBullets(
        jobTitle: 'Intern',
        responsibilities: 'Build features',
        techStack: ['Flutter', 'Firebase'],
      ),
    ).called(1);
  });

  test('GenerateAiSuggestionsUseCase should pass resume data', () async {
    const expected = AiSuggestionsResultEntity(
      suggestions: ['Add measurable outcomes'],
    );
    when(
      () => mockRepository.generateAiSuggestions(
        step: any(named: 'step'),
        resumeData: any(named: 'resumeData'),
      ),
    ).thenAnswer((_) async => const Right(expected));

    final usecase = GenerateAiSuggestionsUseCase(repository: mockRepository);
    final result = await usecase(
      const GenerateAiSuggestionsUseCaseParams(
        step: 'experience',
        resumeData: {'experience': []},
      ),
    );

    expect(result, const Right(expected));
    verify(
      () => mockRepository.generateAiSuggestions(
        step: 'experience',
        resumeData: {'experience': []},
      ),
    ).called(1);
  });

  test('AtsScanUseCase should pass scan payload', () async {
    final expected = buildAtsScanResultEntity();
    when(
      () => mockRepository.atsScan(
        filePath: any(named: 'filePath'),
        targetRole: any(named: 'targetRole'),
        experienceLevel: any(named: 'experienceLevel'),
        jobDescription: any(named: 'jobDescription'),
      ),
    ).thenAnswer((_) async => Right(expected));

    final usecase = AtsScanUseCase(repository: mockRepository);
    final result = await usecase(
      const AtsScanUseCaseParams(
        filePath: '/tmp/resume.pdf',
        targetRole: 'Flutter Developer',
        experienceLevel: 'Mid',
        jobDescription: 'Build apps',
      ),
    );

    expect(result, Right(expected));
    verify(
      () => mockRepository.atsScan(
        filePath: '/tmp/resume.pdf',
        targetRole: 'Flutter Developer',
        experienceLevel: 'Mid',
        jobDescription: 'Build apps',
      ),
    ).called(1);
  });
}
