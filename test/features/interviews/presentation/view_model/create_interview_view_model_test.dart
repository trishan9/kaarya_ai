import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/interviews/domain/usecases/create_interview_usecase.dart';
import 'package:kaarya/features/interviews/presentation/view_model/create_interview_view_model.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_fixtures.dart';

class MockCreateInterviewUseCase extends Mock implements CreateInterviewUseCase {}

void main() {
  late MockCreateInterviewUseCase mockCreateInterviewUseCase;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(
      const CreateInterviewUseCaseParams(
        title: 'Flutter Mock',
        interviewType: 'technical',
        role: 'Flutter Developer',
      ),
    );
  });

  setUp(() {
    mockCreateInterviewUseCase = MockCreateInterviewUseCase();
    container = ProviderContainer(
      overrides: [
        createInterviewUseCaseProvider.overrideWithValue(
          mockCreateInterviewUseCase,
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('CreateInterviewViewModel should save created interview on success', () async {
    final interview = buildInterviewEntity();
    when(
      () => mockCreateInterviewUseCase(any()),
    ).thenAnswer((_) async => Right(interview));

    final viewModel = container.read(createInterviewViewModelProvider.notifier);
    final result = await viewModel.createInterview(
      const CreateInterviewUseCaseParams(
        title: 'Flutter Mock',
        interviewType: 'technical',
        role: 'Flutter Developer',
      ),
    );

    final state = container.read(createInterviewViewModelProvider);
    expect(result, isNull);
    expect(state.isLoading, isFalse);
    expect(state.createdInterview, interview);
    expect(state.errorMessage, isNull);
  });

  test('CreateInterviewViewModel should expose failure on error', () async {
    const failure = ApiFailure(message: 'Unable to create');
    when(
      () => mockCreateInterviewUseCase(any()),
    ).thenAnswer((_) async => const Left(failure));

    final viewModel = container.read(createInterviewViewModelProvider.notifier);
    final result = await viewModel.createInterview(
      const CreateInterviewUseCaseParams(
        title: 'Flutter Mock',
        interviewType: 'technical',
        role: 'Flutter Developer',
      ),
    );

    final state = container.read(createInterviewViewModelProvider);
    expect(result, failure);
    expect(state.isLoading, isFalse);
    expect(state.errorMessage, 'Unable to create');
  });

  test('CreateInterviewViewModel should reset state', () {
    final viewModel = container.read(createInterviewViewModelProvider.notifier);
    viewModel.reset();

    expect(
      container.read(createInterviewViewModelProvider),
      const CreateInterviewState(),
    );
  });
}
