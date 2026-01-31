import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/auth/domain/entities/auth_entity.dart';
import 'package:kaarya/features/auth/domain/repositories/auth_repository.dart';
import 'package:kaarya/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late UpdateProfileUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = UpdateProfileUsecase(authRepository: mockRepository);
  });

  const tName = 'Updated User';
  const tEmail = 'updated@example.com';
  final tPhoto = File('test_assets/profile.png');
  const tUpdatedUser = AuthEntity(
    authId: '1',
    name: tName,
    email: tEmail,
    provider: 'email',
    role: 'user',
    profilePicture: 'https://example.com/updated.png',
  );

  group('UpdateProfileUsecase', () {
    test('Should return AuthEntity when update succeeds', () async {
      when(
        () => mockRepository.updateProfile(tName, tEmail, tPhoto),
      ).thenAnswer((_) async => const Right(tUpdatedUser));

      final result = await usecase(
        UpdateProfileUsecaseParams(name: tName, email: tEmail, photo: tPhoto),
      );

      expect(result, const Right(tUpdatedUser));
      verify(
        () => mockRepository.updateProfile(tName, tEmail, tPhoto),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('Should pass correct values to repository', () async {
      String? capturedName;
      String? capturedEmail;
      File? capturedPhoto;
      when(
        () => mockRepository.updateProfile(
          any<String?>(),
          any<String?>(),
          any<File?>(),
        ),
      ).thenAnswer((invocation) {
        capturedName = invocation.positionalArguments[0] as String?;
        capturedEmail = invocation.positionalArguments[1] as String?;
        capturedPhoto = invocation.positionalArguments[2] as File?;
        return Future.value(const Right(tUpdatedUser));
      });

      await usecase(
        UpdateProfileUsecaseParams(name: tName, email: tEmail, photo: tPhoto),
      );

      expect(capturedName, tName);
      expect(capturedEmail, tEmail);
      expect(capturedPhoto?.path, tPhoto.path);
    });

    test('Should allow null optional parameters', () async {
      when(
        () => mockRepository.updateProfile(null, null, null),
      ).thenAnswer((_) async => const Right(tUpdatedUser));

      final result = await usecase(const UpdateProfileUsecaseParams());

      expect(result, const Right(tUpdatedUser));
      verify(() => mockRepository.updateProfile(null, null, null)).called(1);
    });

    test('Should return failure when update fails', () async {
      const failure = ApiFailure(message: 'Update failed');
      when(
        () => mockRepository.updateProfile(any(), any(), any()),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase(
        UpdateProfileUsecaseParams(name: tName, email: tEmail, photo: tPhoto),
      );

      expect(result, const Left(failure));
      verify(
        () => mockRepository.updateProfile(tName, tEmail, tPhoto),
      ).called(1);
    });

    test('Should return NetworkFailure when there is no internet', () async {
      const failure = NetworkFailure();
      when(
        () => mockRepository.updateProfile(any(), any(), any()),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase(
        UpdateProfileUsecaseParams(name: tName, email: tEmail, photo: tPhoto),
      );

      expect(result, const Left(failure));
      verify(
        () => mockRepository.updateProfile(tName, tEmail, tPhoto),
      ).called(1);
    });

    test('Should pass nulls for omitted fields', () async {
      String? capturedName;
      String? capturedEmail;
      File? capturedPhoto;
      when(
        () => mockRepository.updateProfile(
          any<String?>(),
          any<String?>(),
          any<File?>(),
        ),
      ).thenAnswer((invocation) {
        capturedName = invocation.positionalArguments[0] as String?;
        capturedEmail = invocation.positionalArguments[1] as String?;
        capturedPhoto = invocation.positionalArguments[2] as File?;
        return Future.value(const Right(tUpdatedUser));
      });

      await usecase(const UpdateProfileUsecaseParams(name: tName));

      expect(capturedName, tName);
      expect(capturedEmail, isNull);
      expect(capturedPhoto, isNull);
    });
  });

  group('UpdateProfileUsecaseParams', () {
    test('Should have correct props', () {
      final params = UpdateProfileUsecaseParams(
        name: tName,
        email: tEmail,
        photo: tPhoto,
      );

      expect(params.props, [tName, tEmail, tPhoto]);
    });

    test('Two params with same values should be equal', () {
      final params1 = UpdateProfileUsecaseParams(
        name: tName,
        email: tEmail,
        photo: tPhoto,
      );
      final params2 = UpdateProfileUsecaseParams(
        name: tName,
        email: tEmail,
        photo: tPhoto,
      );

      expect(params1, params2);
    });
  });
}
