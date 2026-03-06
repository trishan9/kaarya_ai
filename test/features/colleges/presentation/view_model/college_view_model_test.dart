import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/colleges/domain/usecases/create_college_usecase.dart';
import 'package:kaarya/features/colleges/domain/usecases/delete_college_usecase.dart';
import 'package:kaarya/features/colleges/domain/usecases/get_college_by_id_usecase.dart';
import 'package:kaarya/features/colleges/domain/usecases/get_college_metrics_usecase.dart';
import 'package:kaarya/features/colleges/domain/usecases/invite_student_usecase.dart';
import 'package:kaarya/features/colleges/domain/usecases/join_by_code_usecase.dart';
import 'package:kaarya/features/colleges/domain/usecases/list_college_workspaces_usecase.dart';
import 'package:kaarya/features/colleges/domain/usecases/list_colleges_usecase.dart';
import 'package:kaarya/features/colleges/domain/usecases/list_students_usecase.dart';
import 'package:kaarya/features/colleges/domain/usecases/remove_student_usecase.dart';
import 'package:kaarya/features/colleges/domain/usecases/reset_invite_code_usecase.dart';
import 'package:kaarya/features/colleges/domain/usecases/update_college_usecase.dart';
import 'package:kaarya/features/colleges/presentation/state/college_state.dart';
import 'package:kaarya/features/colleges/presentation/view_model/college_view_model.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_fixtures.dart';

class MockListCollegesUseCase extends Mock implements ListCollegesUseCase {}

class MockGetCollegeByIdUseCase extends Mock implements GetCollegeByIdUseCase {}

class MockCreateCollegeUseCase extends Mock implements CreateCollegeUseCase {}

class MockUpdateCollegeUseCase extends Mock implements UpdateCollegeUseCase {}

class MockDeleteCollegeUseCase extends Mock implements DeleteCollegeUseCase {}

class MockJoinByCodeUseCase extends Mock implements JoinByCodeUseCase {}

class MockResetInviteCodeUseCase extends Mock implements ResetInviteCodeUseCase {}

class MockListStudentsUseCase extends Mock implements ListStudentsUseCase {}

class MockInviteStudentUseCase extends Mock implements InviteStudentUseCase {}

class MockRemoveStudentUseCase extends Mock implements RemoveStudentUseCase {}

class MockListCollegeWorkspacesUseCase extends Mock
    implements ListCollegeWorkspacesUseCase {}

class MockGetCollegeMetricsUseCase extends Mock
    implements GetCollegeMetricsUseCase {}

void main() {
  late MockListCollegesUseCase mockListCollegesUseCase;
  late MockGetCollegeByIdUseCase mockGetCollegeByIdUseCase;
  late MockCreateCollegeUseCase mockCreateCollegeUseCase;
  late MockUpdateCollegeUseCase mockUpdateCollegeUseCase;
  late MockDeleteCollegeUseCase mockDeleteCollegeUseCase;
  late MockJoinByCodeUseCase mockJoinByCodeUseCase;
  late MockResetInviteCodeUseCase mockResetInviteCodeUseCase;
  late MockListStudentsUseCase mockListStudentsUseCase;
  late MockInviteStudentUseCase mockInviteStudentUseCase;
  late MockRemoveStudentUseCase mockRemoveStudentUseCase;
  late MockListCollegeWorkspacesUseCase mockListCollegeWorkspacesUseCase;
  late MockGetCollegeMetricsUseCase mockGetCollegeMetricsUseCase;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(const ListCollegesUseCaseParams());
    registerFallbackValue(
      const GetCollegeByIdUseCaseParams(collegeId: 'college-1'),
    );
    registerFallbackValue(
      const CreateCollegeUseCaseParams(
        name: 'TU',
        institutionType: 'University',
        location: 'Kathmandu',
      ),
    );
    registerFallbackValue(
      const UpdateCollegeUseCaseParams(collegeId: 'college-1'),
    );
    registerFallbackValue(
      const DeleteCollegeUseCaseParams(collegeId: 'college-1'),
    );
    registerFallbackValue(
      const JoinByCodeUseCaseParams(inviteCode: 'COLLEGE123'),
    );
    registerFallbackValue(
      const ResetInviteCodeUseCaseParams(collegeId: 'college-1'),
    );
    registerFallbackValue(
      const ListStudentsUseCaseParams(collegeId: 'college-1'),
    );
    registerFallbackValue(
      const InviteStudentUseCaseParams(
        collegeId: 'college-1',
        email: 'student@example.com',
      ),
    );
    registerFallbackValue(
      const RemoveStudentUseCaseParams(
        collegeId: 'college-1',
        studentId: 'student-1',
      ),
    );
    registerFallbackValue(const ListCollegeWorkspacesUseCaseParams());
    registerFallbackValue(
      const GetCollegeMetricsUseCaseParams(collegeId: 'college-1'),
    );
  });

  setUp(() {
    mockListCollegesUseCase = MockListCollegesUseCase();
    mockGetCollegeByIdUseCase = MockGetCollegeByIdUseCase();
    mockCreateCollegeUseCase = MockCreateCollegeUseCase();
    mockUpdateCollegeUseCase = MockUpdateCollegeUseCase();
    mockDeleteCollegeUseCase = MockDeleteCollegeUseCase();
    mockJoinByCodeUseCase = MockJoinByCodeUseCase();
    mockResetInviteCodeUseCase = MockResetInviteCodeUseCase();
    mockListStudentsUseCase = MockListStudentsUseCase();
    mockInviteStudentUseCase = MockInviteStudentUseCase();
    mockRemoveStudentUseCase = MockRemoveStudentUseCase();
    mockListCollegeWorkspacesUseCase = MockListCollegeWorkspacesUseCase();
    mockGetCollegeMetricsUseCase = MockGetCollegeMetricsUseCase();

    container = ProviderContainer(
      overrides: [
        listCollegesUseCaseProvider.overrideWithValue(mockListCollegesUseCase),
        getCollegeByIdUseCaseProvider.overrideWithValue(
          mockGetCollegeByIdUseCase,
        ),
        createCollegeUseCaseProvider.overrideWithValue(mockCreateCollegeUseCase),
        updateCollegeUseCaseProvider.overrideWithValue(mockUpdateCollegeUseCase),
        deleteCollegeUseCaseProvider.overrideWithValue(mockDeleteCollegeUseCase),
        joinByCodeUseCaseProvider.overrideWithValue(mockJoinByCodeUseCase),
        resetInviteCodeUseCaseProvider.overrideWithValue(
          mockResetInviteCodeUseCase,
        ),
        listStudentsUseCaseProvider.overrideWithValue(mockListStudentsUseCase),
        inviteStudentUseCaseProvider.overrideWithValue(mockInviteStudentUseCase),
        removeStudentUseCaseProvider.overrideWithValue(mockRemoveStudentUseCase),
        listCollegeWorkspacesUseCaseProvider.overrideWithValue(
          mockListCollegeWorkspacesUseCase,
        ),
        getCollegeMetricsUseCaseProvider.overrideWithValue(
          mockGetCollegeMetricsUseCase,
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('CollegeViewModel should load colleges successfully', () async {
    final colleges = [buildCollegeEntity()];
    when(
      () => mockListCollegesUseCase(any()),
    ).thenAnswer((_) async => Right(colleges));

    final viewModel = container.read(collegeViewModelProvider.notifier);
    await viewModel.loadColleges(search: 'TU');

    final state = container.read(collegeViewModelProvider);
    expect(state.collegesStatus, CollegeLoadStatus.loaded);
    expect(state.colleges, colleges);
    expect(state.searchQuery, 'TU');
  });

  test('CollegeViewModel should load college detail successfully', () async {
    final college = buildCollegeEntity();
    when(
      () => mockGetCollegeByIdUseCase(any()),
    ).thenAnswer((_) async => Right(college));

    final viewModel = container.read(collegeViewModelProvider.notifier);
    await viewModel.loadCollegeDetail('college-1');

    final state = container.read(collegeViewModelProvider);
    expect(state.collegeDetailStatus, CollegeLoadStatus.loaded);
    expect(state.collegeDetail, college);
  });

  test('CollegeViewModel should remove student from current state on success', () async {
    when(
      () => mockRemoveStudentUseCase(any()),
    ).thenAnswer((_) async => const Right(true));

    final viewModel = container.read(collegeViewModelProvider.notifier);
    viewModel.state = CollegeState(
      students: [
        buildStudentMemberEntity(userId: 'student-1'),
        buildStudentMemberEntity(userId: 'student-2'),
      ],
    );

    final result = await viewModel.removeStudent(
      collegeId: 'college-1',
      studentId: 'student-1',
    );

    expect(result, isNull);
    expect(container.read(collegeViewModelProvider).students?.length, 1);
  });

  test('CollegeViewModel should load workspaces and metrics', () async {
    when(
      () => mockListCollegeWorkspacesUseCase(any()),
    ).thenAnswer((_) async => Right([buildCollegeWorkspaceEntity()]));
    when(
      () => mockGetCollegeMetricsUseCase(any()),
    ).thenAnswer((_) async => Right(buildCollegeMetricsEntity()));

    final viewModel = container.read(collegeViewModelProvider.notifier);
    await viewModel.loadWorkspaces();
    await viewModel.loadMetrics(collegeId: 'college-1');

    final state = container.read(collegeViewModelProvider);
    expect(state.workspacesStatus, CollegeLoadStatus.loaded);
    expect(state.metricsStatus, CollegeLoadStatus.loaded);
    expect(state.metrics, isNotNull);
  });

  test('CollegeViewModel should reset state', () {
    final viewModel = container.read(collegeViewModelProvider.notifier);
    viewModel.resetState();

    expect(container.read(collegeViewModelProvider), const CollegeState());
  });
}
