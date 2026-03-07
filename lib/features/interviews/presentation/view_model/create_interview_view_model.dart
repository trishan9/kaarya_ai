import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_entity.dart';
import 'package:kaarya/features/interviews/domain/usecases/create_interview_usecase.dart';

final createInterviewViewModelProvider =
    NotifierProvider<CreateInterviewViewModel, CreateInterviewState>(
        CreateInterviewViewModel.new);

class CreateInterviewState {
  final bool isLoading;
  final String? errorMessage;
  final InterviewEntity? createdInterview;

  const CreateInterviewState({
    this.isLoading = false,
    this.errorMessage,
    this.createdInterview,
  });

  CreateInterviewState copyWith({
    bool? isLoading,
    String? errorMessage,
    InterviewEntity? createdInterview,
  }) {
    return CreateInterviewState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      createdInterview: createdInterview ?? this.createdInterview,
    );
  }
}

class CreateInterviewViewModel extends Notifier<CreateInterviewState> {
  @override
  CreateInterviewState build() => const CreateInterviewState();

  Future<Failure?> createInterview(CreateInterviewUseCaseParams params) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final useCase = ref.read(createInterviewUseCaseProvider);
    final result = await useCase(params);
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return failure;
      },
      (interview) {
        state = state.copyWith(
          isLoading: false,
          createdInterview: interview,
          errorMessage: null,
        );
        return null;
      },
    );
  }

  void reset() {
    state = const CreateInterviewState();
  }
}
