import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/colleges/data/repositories/college_repository.dart';
import 'package:kaarya/features/colleges/domain/repositories/college_repository.dart';
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
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_fixtures.dart';

class MockCollegeRepository extends Mock implements ICollegeRepository {}

void main() {
  late MockCollegeRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockCollegeRepository();
    container = ProviderContainer(
      overrides: [collegeRepositoryProvider.overrideWithValue(mockRepository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('college usecase providers should resolve', () {
    expect(
      container.read(listCollegesUseCaseProvider),
      isA<ListCollegesUseCase>(),
    );
    expect(
      container.read(getCollegeByIdUseCaseProvider),
      isA<GetCollegeByIdUseCase>(),
    );
    expect(
      container.read(createCollegeUseCaseProvider),
      isA<CreateCollegeUseCase>(),
    );
    expect(
      container.read(updateCollegeUseCaseProvider),
      isA<UpdateCollegeUseCase>(),
    );
    expect(
      container.read(deleteCollegeUseCaseProvider),
      isA<DeleteCollegeUseCase>(),
    );
    expect(container.read(joinByCodeUseCaseProvider), isA<JoinByCodeUseCase>());
    expect(
      container.read(resetInviteCodeUseCaseProvider),
      isA<ResetInviteCodeUseCase>(),
    );
    expect(
      container.read(listStudentsUseCaseProvider),
      isA<ListStudentsUseCase>(),
    );
    expect(
      container.read(inviteStudentUseCaseProvider),
      isA<InviteStudentUseCase>(),
    );
    expect(
      container.read(removeStudentUseCaseProvider),
      isA<RemoveStudentUseCase>(),
    );
    expect(
      container.read(listCollegeWorkspacesUseCaseProvider),
      isA<ListCollegeWorkspacesUseCase>(),
    );
    expect(
      container.read(getCollegeMetricsUseCaseProvider),
      isA<GetCollegeMetricsUseCase>(),
    );
  });

  test('ListCollegesUseCase should pass filters to repository', () async {
    final expected = [buildCollegeEntity()];
    when(
      () => mockRepository.listColleges(
        page: any(named: 'page'),
        size: any(named: 'size'),
        search: any(named: 'search'),
      ),
    ).thenAnswer((_) async => Right(expected));

    final usecase = ListCollegesUseCase(repository: mockRepository);
    final result = await usecase(
      const ListCollegesUseCaseParams(page: 2, size: 10, search: 'TU'),
    );

    expect(result, Right(expected));
    verify(
      () => mockRepository.listColleges(page: 2, size: 10, search: 'TU'),
    ).called(1);
  });

  test('GetCollegeByIdUseCase should pass college id', () async {
    final expected = buildCollegeEntity();
    when(
      () => mockRepository.getCollegeById(any()),
    ).thenAnswer((_) async => Right(expected));

    final usecase = GetCollegeByIdUseCase(repository: mockRepository);
    final result = await usecase(
      const GetCollegeByIdUseCaseParams(collegeId: 'college-1'),
    );

    expect(result, Right(expected));
    verify(() => mockRepository.getCollegeById('college-1')).called(1);
  });

  test('CreateCollegeUseCase should pass creation payload', () async {
    final expected = buildCollegeEntity();
    when(
      () => mockRepository.createCollege(
        name: any(named: 'name'),
        institutionType: any(named: 'institutionType'),
        location: any(named: 'location'),
        logoPath: any(named: 'logoPath'),
      ),
    ).thenAnswer((_) async => Right(expected));

    final usecase = CreateCollegeUseCase(repository: mockRepository);
    final result = await usecase(
      const CreateCollegeUseCaseParams(
        name: 'TU',
        institutionType: 'University',
        location: 'Kathmandu',
        logoPath: '/tmp/logo.png',
      ),
    );

    expect(result, Right(expected));
    verify(
      () => mockRepository.createCollege(
        name: 'TU',
        institutionType: 'University',
        location: 'Kathmandu',
        logoPath: '/tmp/logo.png',
      ),
    ).called(1);
  });

  test('UpdateCollegeUseCase should pass update payload', () async {
    final expected = buildCollegeEntity();
    when(
      () => mockRepository.updateCollege(
        collegeId: any(named: 'collegeId'),
        name: any(named: 'name'),
        institutionType: any(named: 'institutionType'),
        location: any(named: 'location'),
        logoPath: any(named: 'logoPath'),
      ),
    ).thenAnswer((_) async => Right(expected));

    final usecase = UpdateCollegeUseCase(repository: mockRepository);
    final result = await usecase(
      const UpdateCollegeUseCaseParams(
        collegeId: 'college-1',
        name: 'Tribhuvan University',
      ),
    );

    expect(result, Right(expected));
    verify(
      () => mockRepository.updateCollege(
        collegeId: 'college-1',
        name: 'Tribhuvan University',
        institutionType: null,
        location: null,
        logoPath: null,
      ),
    ).called(1);
  });

  test('DeleteCollegeUseCase should return repository result', () async {
    when(
      () => mockRepository.deleteCollege(any()),
    ).thenAnswer((_) async => const Right(true));

    final usecase = DeleteCollegeUseCase(repository: mockRepository);
    final result = await usecase(
      const DeleteCollegeUseCaseParams(collegeId: 'college-1'),
    );

    expect(result, const Right(true));
    verify(() => mockRepository.deleteCollege('college-1')).called(1);
  });

  test('JoinByCodeUseCase should pass invite code', () async {
    final expected = buildCollegeEntity();
    when(
      () => mockRepository.joinByCode(any()),
    ).thenAnswer((_) async => Right(expected));

    final usecase = JoinByCodeUseCase(repository: mockRepository);
    final result = await usecase(
      const JoinByCodeUseCaseParams(inviteCode: 'COLLEGE123'),
    );

    expect(result, Right(expected));
    verify(() => mockRepository.joinByCode('COLLEGE123')).called(1);
  });

  test('ResetInviteCodeUseCase should return new invite code', () async {
    when(
      () => mockRepository.resetInviteCode(any()),
    ).thenAnswer((_) async => const Right('NEWCODE'));

    final usecase = ResetInviteCodeUseCase(repository: mockRepository);
    final result = await usecase(
      const ResetInviteCodeUseCaseParams(collegeId: 'college-1'),
    );

    expect(result, const Right('NEWCODE'));
    verify(() => mockRepository.resetInviteCode('college-1')).called(1);
  });

  test('ListStudentsUseCase should pass paging values', () async {
    final expected = [buildStudentMemberEntity()];
    when(
      () => mockRepository.listStudents(
        collegeId: any(named: 'collegeId'),
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) async => Right(expected));

    final usecase = ListStudentsUseCase(repository: mockRepository);
    final result = await usecase(
      const ListStudentsUseCaseParams(
        collegeId: 'college-1',
        page: 3,
        size: 30,
      ),
    );

    expect(result, Right(expected));
    verify(
      () => mockRepository.listStudents(
        collegeId: 'college-1',
        page: 3,
        size: 30,
      ),
    ).called(1);
  });

  test('InviteStudentUseCase should pass invite payload', () async {
    when(
      () => mockRepository.inviteStudent(
        collegeId: any(named: 'collegeId'),
        email: any(named: 'email'),
        program: any(named: 'program'),
        year: any(named: 'year'),
      ),
    ).thenAnswer((_) async => const Right(true));

    final usecase = InviteStudentUseCase(repository: mockRepository);
    final result = await usecase(
      const InviteStudentUseCaseParams(
        collegeId: 'college-1',
        email: 'student@example.com',
        program: 'BSc CSIT',
        year: 4,
      ),
    );

    expect(result, const Right(true));
    verify(
      () => mockRepository.inviteStudent(
        collegeId: 'college-1',
        email: 'student@example.com',
        program: 'BSc CSIT',
        year: 4,
      ),
    ).called(1);
  });

  test('RemoveStudentUseCase should return repository failure', () async {
    const failure = ApiFailure(message: 'Remove failed');
    when(
      () => mockRepository.removeStudent(
        collegeId: any(named: 'collegeId'),
        studentId: any(named: 'studentId'),
      ),
    ).thenAnswer((_) async => const Left(failure));

    final usecase = RemoveStudentUseCase(repository: mockRepository);
    final result = await usecase(
      const RemoveStudentUseCaseParams(
        collegeId: 'college-1',
        studentId: 'student-1',
      ),
    );

    expect(result, const Left(failure));
    verify(
      () => mockRepository.removeStudent(
        collegeId: 'college-1',
        studentId: 'student-1',
      ),
    ).called(1);
  });

  test('ListCollegeWorkspacesUseCase should pass paging values', () async {
    final expected = [buildCollegeWorkspaceEntity()];
    when(
      () => mockRepository.listCollegeWorkspaces(
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) async => Right(expected));

    final usecase = ListCollegeWorkspacesUseCase(repository: mockRepository);
    final result = await usecase(
      const ListCollegeWorkspacesUseCaseParams(page: 2, size: 50),
    );

    expect(result, Right(expected));
    verify(
      () => mockRepository.listCollegeWorkspaces(page: 2, size: 50),
    ).called(1);
  });

  test('GetCollegeMetricsUseCase should pass college id', () async {
    final expected = buildCollegeMetricsEntity();
    when(
      () => mockRepository.getCollegeMetrics(any()),
    ).thenAnswer((_) async => Right(expected));

    final usecase = GetCollegeMetricsUseCase(repository: mockRepository);
    final result = await usecase(
      const GetCollegeMetricsUseCaseParams(collegeId: 'college-1'),
    );

    expect(result, Right(expected));
    verify(() => mockRepository.getCollegeMetrics('college-1')).called(1);
  });
}
