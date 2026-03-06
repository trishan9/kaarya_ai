import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/resources/domain/usecases/create_course_usecase.dart';
import 'package:kaarya/features/resources/domain/usecases/delete_course_usecase.dart';
import 'package:kaarya/features/resources/domain/usecases/get_course_by_id_usecase.dart';
import 'package:kaarya/features/resources/domain/usecases/list_courses_usecase.dart';
import 'package:kaarya/features/resources/domain/usecases/update_course_usecase.dart';
import 'package:kaarya/features/resources/presentation/state/resource_state.dart';
import 'package:kaarya/features/resources/presentation/view_model/resource_view_model.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_fixtures.dart';

class MockListCoursesUseCase extends Mock implements ListCoursesUseCase {}

class MockGetCourseByIdUseCase extends Mock implements GetCourseByIdUseCase {}

class MockCreateCourseUseCase extends Mock implements CreateCourseUseCase {}

class MockUpdateCourseUseCase extends Mock implements UpdateCourseUseCase {}

class MockDeleteCourseUseCase extends Mock implements DeleteCourseUseCase {}

void main() {
  late MockListCoursesUseCase mockListCoursesUseCase;
  late MockGetCourseByIdUseCase mockGetCourseByIdUseCase;
  late MockCreateCourseUseCase mockCreateCourseUseCase;
  late MockUpdateCourseUseCase mockUpdateCourseUseCase;
  late MockDeleteCourseUseCase mockDeleteCourseUseCase;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(const ListCoursesUseCaseParams());
    registerFallbackValue(
      const GetCourseByIdUseCaseParams(courseId: 'course-1'),
    );
    registerFallbackValue(
      const CreateCourseUseCaseParams(
        title: 'Flutter Basics',
        category: 'mobile',
        generationMode: 'guided',
        difficulty: 'beginner',
        targetRoles: ['Flutter Developer'],
      ),
    );
    registerFallbackValue(
      const UpdateCourseUseCaseParams(
        courseId: 'course-1',
        fields: {'title': 'Updated'},
      ),
    );
    registerFallbackValue(
      const DeleteCourseUseCaseParams(courseId: 'course-1'),
    );
  });

  setUp(() {
    mockListCoursesUseCase = MockListCoursesUseCase();
    mockGetCourseByIdUseCase = MockGetCourseByIdUseCase();
    mockCreateCourseUseCase = MockCreateCourseUseCase();
    mockUpdateCourseUseCase = MockUpdateCourseUseCase();
    mockDeleteCourseUseCase = MockDeleteCourseUseCase();

    container = ProviderContainer(
      overrides: [
        listCoursesUseCaseProvider.overrideWithValue(mockListCoursesUseCase),
        getCourseByIdUseCaseProvider.overrideWithValue(
          mockGetCourseByIdUseCase,
        ),
        createCourseUseCaseProvider.overrideWithValue(mockCreateCourseUseCase),
        updateCourseUseCaseProvider.overrideWithValue(mockUpdateCourseUseCase),
        deleteCourseUseCaseProvider.overrideWithValue(mockDeleteCourseUseCase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('ResourceViewModel', () {
    test('should load courses successfully', () async {
      final courses = buildResourceCoursesListEntity();
      when(
        () => mockListCoursesUseCase(any()),
      ).thenAnswer((_) async => Right(courses));

      final viewModel = container.read(resourceViewModelProvider.notifier);
      await viewModel.loadCourses(search: 'flutter');

      final state = container.read(resourceViewModelProvider);
      expect(state.coursesListStatus, ResourceLoadStatus.loaded);
      expect(state.coursesListData, courses);
      expect(state.searchQuery, 'flutter');
    });

    test('should skip reloading courses when data is already loaded', () async {
      final courses = buildResourceCoursesListEntity();
      when(
        () => mockListCoursesUseCase(any()),
      ).thenAnswer((_) async => Right(courses));

      final viewModel = container.read(resourceViewModelProvider.notifier);
      await viewModel.loadCourses();
      await viewModel.loadCourses();

      verify(() => mockListCoursesUseCase(any())).called(1);
    });

    test('should load course detail successfully', () async {
      final course = buildResourceCourseEntity();
      when(
        () => mockGetCourseByIdUseCase(any()),
      ).thenAnswer((_) async => Right(course));

      final viewModel = container.read(resourceViewModelProvider.notifier);
      await viewModel.loadCourseDetail('course-1');

      final state = container.read(resourceViewModelProvider);
      expect(state.courseDetailStatus, ResourceLoadStatus.loaded);
      expect(state.courseDetailData, course);
    });

    test('should create course and clear error', () async {
      final course = buildResourceCourseEntity();
      when(
        () => mockCreateCourseUseCase(any()),
      ).thenAnswer((_) async => Right(course));

      final viewModel = container.read(resourceViewModelProvider.notifier);
      final failure = await viewModel.createCourse(
        title: 'Flutter Basics',
        category: 'mobile',
        generationMode: 'guided',
        difficulty: 'beginner',
        targetRoles: const ['Flutter Developer'],
      );

      expect(failure, isNull);
      expect(
        container.read(resourceViewModelProvider).createCourseStatus,
        ResourceLoadStatus.loaded,
      );
    });

    test('should return create course failure', () async {
      const failure = ApiFailure(message: 'Create failed');
      when(
        () => mockCreateCourseUseCase(any()),
      ).thenAnswer((_) async => const Left(failure));

      final viewModel = container.read(resourceViewModelProvider.notifier);
      final result = await viewModel.createCourse(
        title: 'Flutter Basics',
        category: 'mobile',
        generationMode: 'guided',
        difficulty: 'beginner',
        targetRoles: const ['Flutter Developer'],
      );

      expect(result, failure);
      expect(
        container.read(resourceViewModelProvider).createCourseStatus,
        ResourceLoadStatus.error,
      );
    });

    test('should update course detail on success', () async {
      final course = buildResourceCourseEntity();
      when(
        () => mockUpdateCourseUseCase(any()),
      ).thenAnswer((_) async => Right(course));

      final viewModel = container.read(resourceViewModelProvider.notifier);
      final result = await viewModel.updateCourse(
        courseId: 'course-1',
        fields: const {'title': 'Updated'},
      );

      expect(result, isNull);
      expect(container.read(resourceViewModelProvider).courseDetailData, course);
    });

    test('should delete course successfully', () async {
      when(
        () => mockDeleteCourseUseCase(any()),
      ).thenAnswer((_) async => const Right(true));

      final viewModel = container.read(resourceViewModelProvider.notifier);
      final result = await viewModel.deleteCourse('course-1');

      expect(result, isNull);
      expect(
        container.read(resourceViewModelProvider).deleteCourseStatus,
        ResourceLoadStatus.loaded,
      );
    });

    test('should reset state', () {
      final viewModel = container.read(resourceViewModelProvider.notifier);
      viewModel.resetState();

      expect(container.read(resourceViewModelProvider), const ResourceState());
    });
  });
}
