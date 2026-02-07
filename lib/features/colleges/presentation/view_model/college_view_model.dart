import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/colleges/domain/entities/college_entity.dart';
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

final collegeViewModelProvider =
    NotifierProvider<CollegeViewModel, CollegeState>(CollegeViewModel.new);

class CollegeViewModel extends Notifier<CollegeState> {
  late final ListCollegesUseCase _listCollegesUseCase;
  late final GetCollegeByIdUseCase _getCollegeByIdUseCase;
  late final CreateCollegeUseCase _createCollegeUseCase;
  late final UpdateCollegeUseCase _updateCollegeUseCase;
  late final DeleteCollegeUseCase _deleteCollegeUseCase;
  late final JoinByCodeUseCase _joinByCodeUseCase;
  late final ResetInviteCodeUseCase _resetInviteCodeUseCase;
  late final ListStudentsUseCase _listStudentsUseCase;
  late final InviteStudentUseCase _inviteStudentUseCase;
  late final RemoveStudentUseCase _removeStudentUseCase;
  late final ListCollegeWorkspacesUseCase _listCollegeWorkspacesUseCase;
  late final GetCollegeMetricsUseCase _getCollegeMetricsUseCase;

  @override
  CollegeState build() {
    _listCollegesUseCase = ref.read(listCollegesUseCaseProvider);
    _getCollegeByIdUseCase = ref.read(getCollegeByIdUseCaseProvider);
    _createCollegeUseCase = ref.read(createCollegeUseCaseProvider);
    _updateCollegeUseCase = ref.read(updateCollegeUseCaseProvider);
    _deleteCollegeUseCase = ref.read(deleteCollegeUseCaseProvider);
    _joinByCodeUseCase = ref.read(joinByCodeUseCaseProvider);
    _resetInviteCodeUseCase = ref.read(resetInviteCodeUseCaseProvider);
    _listStudentsUseCase = ref.read(listStudentsUseCaseProvider);
    _inviteStudentUseCase = ref.read(inviteStudentUseCaseProvider);
    _removeStudentUseCase = ref.read(removeStudentUseCaseProvider);
    _listCollegeWorkspacesUseCase = ref.read(
      listCollegeWorkspacesUseCaseProvider,
    );
    _getCollegeMetricsUseCase = ref.read(getCollegeMetricsUseCaseProvider);
    return const CollegeState();
  }

  void resetState() {
    state = const CollegeState();
  }

  Future<void> loadColleges({
    String? search,
    int page = 1,
    int size = 20,
    bool forceRefresh = false,
  }) async {
    final nextSearch = (search ?? state.searchQuery).trim();
    final queryChanged = nextSearch != state.searchQuery;

    if (!forceRefresh &&
        !queryChanged &&
        state.collegesStatus == CollegeLoadStatus.loaded &&
        state.colleges != null) {
      return;
    }

    state = state.copyWith(
      collegesStatus: CollegeLoadStatus.loading,
      collegesErrorMessage: null,
      searchQuery: nextSearch,
    );

    final result = await _listCollegesUseCase(
      ListCollegesUseCaseParams(
        page: page,
        size: size,
        search: nextSearch.isEmpty ? null : nextSearch,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        collegesStatus: CollegeLoadStatus.error,
        collegesErrorMessage: failure.message,
      ),
      (colleges) => state = state.copyWith(
        collegesStatus: CollegeLoadStatus.loaded,
        colleges: colleges,
        collegesErrorMessage: null,
      ),
    );
  }

  Future<void> loadCollegeDetail(String collegeId) async {
    state = state.copyWith(
      collegeDetailStatus: CollegeLoadStatus.loading,
      collegeDetail: null,
      collegeDetailErrorMessage: null,
    );

    final result = await _getCollegeByIdUseCase(
      GetCollegeByIdUseCaseParams(collegeId: collegeId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        collegeDetailStatus: CollegeLoadStatus.error,
        collegeDetailErrorMessage: failure.message,
      ),
      (college) => state = state.copyWith(
        collegeDetailStatus: CollegeLoadStatus.loaded,
        collegeDetail: college,
        collegeDetailErrorMessage: null,
      ),
    );
  }

  Future<(CollegeEntity?, Failure?)> createCollege({
    required String name,
    required String institutionType,
    required String location,
    String? logoPath,
  }) async {
    final result = await _createCollegeUseCase(
      CreateCollegeUseCaseParams(
        name: name,
        institutionType: institutionType,
        location: location,
        logoPath: logoPath,
      ),
    );

    return result.fold(
      (failure) => (null, failure),
      (college) => (college, null),
    );
  }

  Future<(CollegeEntity?, Failure?)> updateCollege({
    required String collegeId,
    String? name,
    String? institutionType,
    String? location,
    String? logoPath,
  }) async {
    final result = await _updateCollegeUseCase(
      UpdateCollegeUseCaseParams(
        collegeId: collegeId,
        name: name,
        institutionType: institutionType,
        location: location,
        logoPath: logoPath,
      ),
    );

    return result.fold((failure) => (null, failure), (college) {
      if (state.collegeDetail?.id == collegeId) {
        state = state.copyWith(collegeDetail: college);
      }
      return (college, null);
    });
  }

  Future<Failure?> deleteCollege(String collegeId) async {
    final result = await _deleteCollegeUseCase(
      DeleteCollegeUseCaseParams(collegeId: collegeId),
    );

    return result.fold((failure) => failure, (_) {
      final currentList = state.colleges;
      if (currentList != null) {
        state = state.copyWith(
          colleges: currentList.where((c) => c.id != collegeId).toList(),
        );
      }
      return null;
    });
  }

  Future<(CollegeEntity?, Failure?)> joinByCode(String inviteCode) async {
    final result = await _joinByCodeUseCase(
      JoinByCodeUseCaseParams(inviteCode: inviteCode),
    );

    return result.fold(
      (failure) => (null, failure),
      (college) => (college, null),
    );
  }

  Future<(String?, Failure?)> resetInviteCode(String collegeId) async {
    final result = await _resetInviteCodeUseCase(
      ResetInviteCodeUseCaseParams(collegeId: collegeId),
    );

    return result.fold(
      (failure) => (null, failure),
      (newCode) => (newCode, null),
    );
  }

  Future<void> loadStudents({
    required String collegeId,
    int page = 1,
    int size = 20,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        state.studentsStatus == CollegeLoadStatus.loaded &&
        state.students != null) {
      return;
    }

    state = state.copyWith(
      studentsStatus: CollegeLoadStatus.loading,
      studentsErrorMessage: null,
    );

    final result = await _listStudentsUseCase(
      ListStudentsUseCaseParams(collegeId: collegeId, page: page, size: size),
    );

    result.fold(
      (failure) => state = state.copyWith(
        studentsStatus: CollegeLoadStatus.error,
        studentsErrorMessage: failure.message,
      ),
      (students) => state = state.copyWith(
        studentsStatus: CollegeLoadStatus.loaded,
        students: students,
        studentsErrorMessage: null,
      ),
    );
  }

  Future<Failure?> inviteStudent({
    required String collegeId,
    required String email,
  }) async {
    final result = await _inviteStudentUseCase(
      InviteStudentUseCaseParams(collegeId: collegeId, email: email),
    );

    return result.fold((failure) => failure, (_) => null);
  }

  Future<Failure?> removeStudent({
    required String collegeId,
    required String studentId,
  }) async {
    final result = await _removeStudentUseCase(
      RemoveStudentUseCaseParams(collegeId: collegeId, studentId: studentId),
    );

    return result.fold((failure) => failure, (_) {
      final currentStudents = state.students;
      if (currentStudents != null) {
        state = state.copyWith(
          students: currentStudents
              .where((s) => s.userId != studentId)
              .toList(),
        );
      }
      return null;
    });
  }

  Future<void> loadWorkspaces({
    int page = 1,
    int size = 20,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        state.workspacesStatus == CollegeLoadStatus.loaded &&
        state.workspaces != null) {
      return;
    }

    state = state.copyWith(
      workspacesStatus: CollegeLoadStatus.loading,
      workspacesErrorMessage: null,
    );

    final result = await _listCollegeWorkspacesUseCase(
      ListCollegeWorkspacesUseCaseParams(page: page, size: size),
    );

    result.fold(
      (failure) => state = state.copyWith(
        workspacesStatus: CollegeLoadStatus.error,
        workspacesErrorMessage: failure.message,
      ),
      (workspaces) => state = state.copyWith(
        workspacesStatus: CollegeLoadStatus.loaded,
        workspaces: workspaces,
        workspacesErrorMessage: null,
      ),
    );
  }

  Future<void> loadMetrics({
    required String collegeId,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        state.metricsStatus == CollegeLoadStatus.loaded &&
        state.metrics != null) {
      return;
    }

    state = state.copyWith(
      metricsStatus: CollegeLoadStatus.loading,
      metricsErrorMessage: null,
    );

    final result = await _getCollegeMetricsUseCase(
      GetCollegeMetricsUseCaseParams(collegeId: collegeId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        metricsStatus: CollegeLoadStatus.error,
        metricsErrorMessage: failure.message,
      ),
      (metrics) => state = state.copyWith(
        metricsStatus: CollegeLoadStatus.loaded,
        metrics: metrics,
        metricsErrorMessage: null,
      ),
    );
  }
}
