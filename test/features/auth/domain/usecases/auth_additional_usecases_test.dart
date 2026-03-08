import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/auth/data/repositories/auth_repository.dart';
import 'package:kaarya/features/auth/domain/repositories/auth_repository.dart';
import 'package:kaarya/features/auth/domain/usecases/change_password_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/confirm_reset_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/exchange_oauth_result_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/get_linked_accounts_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/get_oauth_provider_status_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/login_with_google_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/request_password_reset_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/unlink_oauth_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/upload_certification_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/verify_reset_otp_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_fixtures.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockAuthRepository();
    container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(mockRepository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('additional auth usecase providers should resolve', () {
    expect(
      container.read(changePasswordUseCaseProvider),
      isA<ChangePasswordUseCase>(),
    );
    expect(
      container.read(confirmResetUseCaseProvider),
      isA<ConfirmResetUseCase>(),
    );
    expect(
      container.read(exchangeOAuthResultUseCaseProvider),
      isA<ExchangeOAuthResultUseCase>(),
    );
    expect(
      container.read(getLinkedAccountsUseCaseProvider),
      isA<GetLinkedAccountsUseCase>(),
    );
    expect(
      container.read(getOAuthProviderStatusUseCaseProvider),
      isA<GetOAuthProviderStatusUseCase>(),
    );
    expect(
      container.read(loginWithGoogleUseCaseProvider),
      isA<LoginWithGoogleUseCase>(),
    );
    expect(
      container.read(requestPasswordResetUseCaseProvider),
      isA<RequestPasswordResetUseCase>(),
    );
    expect(
      container.read(unlinkOAuthUseCaseProvider),
      isA<UnlinkOAuthUseCase>(),
    );
    expect(
      container.read(uploadCertificationUseCaseProvider),
      isA<UploadCertificationUseCase>(),
    );
    expect(
      container.read(verifyResetOtpUseCaseProvider),
      isA<VerifyResetOtpUseCase>(),
    );
  });

  test('ChangePasswordUseCase should call repository with passwords', () async {
    when(
      () => mockRepository.changePassword(any(), any(), any()),
    ).thenAnswer((_) async => const Right(true));

    final usecase = ChangePasswordUseCase(authRepository: mockRepository);
    const params = ChangePasswordParams(
      currentPassword: 'old123',
      newPassword: 'new123456',
      confirmNewPassword: 'new123456',
    );

    final result = await usecase(params);

    expect(result, const Right(true));
    verify(
      () => mockRepository.changePassword('old123', 'new123456', 'new123456'),
    ).called(1);
  });

  test('ConfirmResetUseCase should call repository', () async {
    when(
      () => mockRepository.confirmPasswordReset(any(), any(), any()),
    ).thenAnswer((_) async => const Right(true));

    final usecase = ConfirmResetUseCase(authRepository: mockRepository);
    const params = ConfirmResetParams(
      token: 'reset-token',
      password: 'new123456',
      confirmPassword: 'new123456',
    );

    final result = await usecase(params);

    expect(result, const Right(true));
    verify(
      () => mockRepository.confirmPasswordReset(
        'reset-token',
        'new123456',
        'new123456',
      ),
    ).called(1);
  });

  test('ExchangeOAuthResultUseCase should exchange result token', () async {
    final expected = buildAuthEntity();
    when(
      () => mockRepository.exchangeOAuthResult(any()),
    ).thenAnswer((_) async => Right(expected));

    final usecase = ExchangeOAuthResultUseCase(authRepository: mockRepository);
    final result = await usecase(
      const ExchangeOAuthResultUseCaseParams(resultToken: 'oauth-result'),
    );

    expect(result, Right(expected));
    verify(() => mockRepository.exchangeOAuthResult('oauth-result')).called(1);
  });

  test('GetLinkedAccountsUseCase should return repository result', () async {
    final expected = [buildLinkedAccountEntity()];
    when(
      () => mockRepository.getLinkedAccounts(),
    ).thenAnswer((_) async => Right(expected));

    final usecase = GetLinkedAccountsUseCase(authRepository: mockRepository);
    final result = await usecase();

    expect(result, Right(expected));
    verify(() => mockRepository.getLinkedAccounts()).called(1);
  });

  test(
    'GetOAuthProviderStatusUseCase should call repository with provider',
    () async {
      final expected = buildOAuthProviderStatus();
      when(
        () => mockRepository.getOAuthProviderStatus(any()),
      ).thenAnswer((_) async => Right(expected));

      final usecase = GetOAuthProviderStatusUseCase(
        authRepository: mockRepository,
      );
      final result = await usecase(
        const GetOAuthProviderStatusParams(provider: 'google'),
      );

      expect(result, Right(expected));
      verify(() => mockRepository.getOAuthProviderStatus('google')).called(1);
    },
  );

  test('LoginWithGoogleUseCase should pass server client id', () async {
    final expected = buildAuthEntity();
    when(
      () => mockRepository.loginWithGoogle(any()),
    ).thenAnswer((_) async => Right(expected));

    final usecase = LoginWithGoogleUseCase(authRepository: mockRepository);
    final result = await usecase(
      const LoginWithGoogleUseCaseParams(serverClientId: 'server-client-id'),
    );

    expect(result, Right(expected));
    verify(() => mockRepository.loginWithGoogle('server-client-id')).called(1);
  });

  test('RequestPasswordResetUseCase should pass email to repository', () async {
    when(
      () => mockRepository.requestPasswordReset(any()),
    ).thenAnswer((_) async => const Right(true));

    final usecase = RequestPasswordResetUseCase(authRepository: mockRepository);
    final result = await usecase(
      const RequestPasswordResetParams(email: 'test@example.com'),
    );

    expect(result, const Right(true));
    verify(
      () => mockRepository.requestPasswordReset('test@example.com'),
    ).called(1);
  });

  test('UnlinkOAuthUseCase should call repository', () async {
    when(
      () => mockRepository.unlinkOAuth(any()),
    ).thenAnswer((_) async => const Right(true));

    final usecase = UnlinkOAuthUseCase(authRepository: mockRepository);
    final result = await usecase(const UnlinkOAuthParams(provider: 'google'));

    expect(result, const Right(true));
    verify(() => mockRepository.unlinkOAuth('google')).called(1);
  });

  test('UploadCertificationUseCase should pass file path', () async {
    when(
      () => mockRepository.uploadCertification(any()),
    ).thenAnswer((_) async => const Right('https://example.com/cert.pdf'));

    final usecase = UploadCertificationUseCase(authRepository: mockRepository);
    final result = await usecase(
      const UploadCertificationParams(filePath: '/tmp/cert.pdf'),
    );

    expect(result, const Right('https://example.com/cert.pdf'));
    verify(() => mockRepository.uploadCertification('/tmp/cert.pdf')).called(1);
  });

  test('VerifyResetOtpUseCase should return repository failure', () async {
    const failure = ApiFailure(message: 'Invalid OTP');
    when(
      () => mockRepository.verifyPasswordResetOtp(any(), any()),
    ).thenAnswer((_) async => const Left(failure));

    final usecase = VerifyResetOtpUseCase(authRepository: mockRepository);
    final result = await usecase(
      const VerifyResetOtpParams(email: 'test@example.com', otp: '123456'),
    );

    expect(result, const Left(failure));
    verify(
      () => mockRepository.verifyPasswordResetOtp('test@example.com', '123456'),
    ).called(1);
  });
}
