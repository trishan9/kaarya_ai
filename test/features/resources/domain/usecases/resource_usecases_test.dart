import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/resources/data/repositories/resource_repository.dart';
import 'package:kaarya/features/resources/domain/repositories/resource_repository.dart';
import 'package:kaarya/features/resources/domain/usecases/create_course_usecase.dart';
import 'package:kaarya/features/resources/domain/usecases/delete_course_usecase.dart';
import 'package:kaarya/features/resources/domain/usecases/get_course_by_id_usecase.dart';
import 'package:kaarya/features/resources/domain/usecases/list_courses_usecase.dart';
import 'package:kaarya/features/resources/domain/usecases/update_course_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_fixtures.dart';

class MockResourceRepository extends Mock implements IResourceRepository {}

void main() {
  late MockResourceRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockResourceRepository();
    container = ProviderContainer(
      overrides: [resourceRepositoryProvider.overrideWithValue(mockRepository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('resource usecase providers should resolve', () {
    expect(
      container.read(listCoursesUseCaseProvider),
      isA<ListCoursesUseCase>(),
    );
    expect(
      container.read(getCourseByIdUseCaseProvider),
      isA<GetCourseByIdUseCase>(),
    );
    expect(
      container.read(createCourseUseCaseProvider),
      isA<CreateCourseUseCase>(),
    );
    expect(
      container.read(updateCourseUseCaseProvider),
      isA<UpdateCourseUseCase>(),
    );
    expect(
      container.read(deleteCourseUseCaseProvider),
      isA<DeleteCourseUseCase>(),
    );
  });

  test('ListCoursesUseCase should pass list filters to repository', () async {
    final expected = buildResourceCoursesListEntity();
    when(
      () => mockRepository.listCourses(
        page: any(named: 'page'),
        size: any(named: 'size'),
        search: any(named: 'search'),
        difficulty: any(named: 'difficulty'),
        category: any(named: 'category'),
      ),
    ).thenAnswer((_) async => Right(expected));

    final usecase = ListCoursesUseCase(repository: mockRepository);
    const params = ListCoursesUseCaseParams(
      page: 2,
      size: 10,
      search: 'flutter',
      difficulty: 'beginner',
      category: 'mobile',
    );

    final result = await usecase(params);

    expect(result, Right(expected));
    verify(
      () => mockRepository.listCourses(
        page: 2,
        size: 10,
        search: 'flutter',
        difficulty: 'beginner',
        category: 'mobile',
      ),
    ).called(1);
  });

  test('GetCourseByIdUseCase should pass id to repository', () async {
    final expected = buildResourceCourseEntity();
    when(
      () => mockRepository.getCourseById(any()),
    ).thenAnswer((_) async => Right(expected));

    final usecase = GetCourseByIdUseCase(repository: mockRepository);
    final result = await usecase(
      const GetCourseByIdUseCaseParams(courseId: 'course-1'),
    );

    expect(result, Right(expected));
    verify(() => mockRepository.getCourseById('course-1')).called(1);
  });

  test(
    'CreateCourseUseCase should pass creation payload to repository',
    () async {
      final expected = buildResourceCourseEntity();
      when(
        () => mockRepository.createCourse(
          title: any(named: 'title'),
          description: any(named: 'description'),
          category: any(named: 'category'),
          generationMode: any(named: 'generationMode'),
          difficulty: any(named: 'difficulty'),
          targetRoles: any(named: 'targetRoles'),
          chapterCount: any(named: 'chapterCount'),
          visibility: any(named: 'visibility'),
          includeVideoRecommendations: any(
            named: 'includeVideoRecommendations',
          ),
          promptContext: any(named: 'promptContext'),
          jobDescriptionContext: any(named: 'jobDescriptionContext'),
        ),
      ).thenAnswer((_) async => Right(expected));

      final usecase = CreateCourseUseCase(repository: mockRepository);
      final result = await usecase(
        const CreateCourseUseCaseParams(
          title: 'Flutter Basics',
          description: 'Learn Flutter',
          category: 'mobile',
          generationMode: 'guided',
          difficulty: 'beginner',
          targetRoles: ['Flutter Developer'],
          chapterCount: 4,
          visibility: 'public',
          includeVideoRecommendations: true,
          promptContext: 'prompt',
          jobDescriptionContext: 'job description',
        ),
      );

      expect(result, Right(expected));
      verify(
        () => mockRepository.createCourse(
          title: 'Flutter Basics',
          description: 'Learn Flutter',
          category: 'mobile',
          generationMode: 'guided',
          difficulty: 'beginner',
          targetRoles: ['Flutter Developer'],
          chapterCount: 4,
          visibility: 'public',
          includeVideoRecommendations: true,
          promptContext: 'prompt',
          jobDescriptionContext: 'job description',
        ),
      ).called(1);
    },
  );

  test(
    'UpdateCourseUseCase should pass update payload to repository',
    () async {
      final expected = buildResourceCourseEntity();
      when(
        () => mockRepository.updateCourse(
          courseId: any(named: 'courseId'),
          fields: any(named: 'fields'),
        ),
      ).thenAnswer((_) async => Right(expected));

      final usecase = UpdateCourseUseCase(repository: mockRepository);
      final result = await usecase(
        const UpdateCourseUseCaseParams(
          courseId: 'course-1',
          fields: {'title': 'Updated'},
        ),
      );

      expect(result, Right(expected));
      verify(
        () => mockRepository.updateCourse(
          courseId: 'course-1',
          fields: {'title': 'Updated'},
        ),
      ).called(1);
    },
  );

  test('DeleteCourseUseCase should return repository result', () async {
    when(
      () => mockRepository.deleteCourse(any()),
    ).thenAnswer((_) async => const Right(true));

    final usecase = DeleteCourseUseCase(repository: mockRepository);
    final result = await usecase(
      const DeleteCourseUseCaseParams(courseId: 'course-1'),
    );

    expect(result, const Right(true));
    verify(() => mockRepository.deleteCourse('course-1')).called(1);
  });

  test('DeleteCourseUseCase should return repository failure', () async {
    const failure = ApiFailure(message: 'Delete failed');
    when(
      () => mockRepository.deleteCourse(any()),
    ).thenAnswer((_) async => const Left(failure));

    final usecase = DeleteCourseUseCase(repository: mockRepository);
    final result = await usecase(
      const DeleteCourseUseCaseParams(courseId: 'course-1'),
    );

    expect(result, const Left(failure));
  });
}
