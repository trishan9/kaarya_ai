import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/auth/domain/repositories/auth_repository.dart';
import 'package:kaarya/features/auth/domain/usecases/logout_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LogoutUseCase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LogoutUseCase(authRepository: mockRepository);
  });

  group('LogoutUseCase', () {
    test('Should return true when logout is successful', () async {
      when(
        () => mockRepository.logoutUser(),
      ).thenAnswer((_) async => const Right(true));

      final result = await usecase();

      expect(result, const Right(true));
      verify(() => mockRepository.logoutUser()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('Should return failure when logout fails', () async {
      const failure = ApiFailure(message: 'Logout failed');
      when(
        () => mockRepository.logoutUser(),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase();

      expect(result, const Left(failure));
      verify(() => mockRepository.logoutUser()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('Should return NetworkFailure when there is no internet', () async {
      const failure = NetworkFailure();
      when(
        () => mockRepository.logoutUser(),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase();

      expect(result, const Left(failure));
      verify(() => mockRepository.logoutUser()).called(1);
    });
  });
}
