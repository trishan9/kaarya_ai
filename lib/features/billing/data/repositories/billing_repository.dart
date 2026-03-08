import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/services/connectivity/network_info.dart';
import 'package:kaarya/features/billing/data/datasources/billing_datasource.dart';
import 'package:kaarya/features/billing/data/datasources/remote/billing_remote_datasource.dart';
import 'package:kaarya/features/billing/domain/entities/billing_summary_entity.dart';
import 'package:kaarya/features/billing/domain/repositories/billing_repository.dart';

final billingRepositoryProvider = Provider<IBillingRepository>((ref) {
  return BillingRepository(
    remoteDataSource: ref.read(billingRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class BillingRepository implements IBillingRepository {
  BillingRepository({
    required IBillingRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _networkInfo = networkInfo;

  final IBillingRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, BillingSummaryEntity>> getBillingSummary() async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection to load billing.'),
      );
    }

    try {
      final result = await _remoteDataSource.getBillingSummary();
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(
        _mapDioException(e, fallbackMessage: 'Failed to load billing summary.'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, StripeCheckoutSessionEntity>>
  createStripeCheckoutSession({
    required String successPath,
    required String cancelPath,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection to start checkout.'),
      );
    }

    try {
      final result = await _remoteDataSource.createStripeCheckoutSession(
        successPath: successPath,
        cancelPath: cancelPath,
      );
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(
        _mapDioException(
          e,
          fallbackMessage: 'Failed to start Stripe checkout.',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, StripePortalSessionEntity>> createStripePortalSession({
    required String returnPath,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection to open billing portal.',
        ),
      );
    }

    try {
      final result = await _remoteDataSource.createStripePortalSession(
        returnPath: returnPath,
      );
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(
        _mapDioException(
          e,
          fallbackMessage: 'Failed to open Stripe billing portal.',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, StripeCheckoutVerificationEntity>>
  verifyStripeCheckoutSession(String sessionId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection to verify payment.'),
      );
    }

    try {
      final result = await _remoteDataSource.verifyStripeCheckoutSession(
        sessionId,
      );
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(
        _mapDioException(
          e,
          fallbackMessage: 'Payment completed, but verification failed.',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  Failure _mapDioException(DioException e, {required String fallbackMessage}) {
    final data = e.response?.data;
    String? message;
    if (data is Map && data['message'] is String) {
      message = data['message'] as String;
    }
    return ApiFailure(
      statusCode: e.response?.statusCode,
      message: message ?? e.message ?? fallbackMessage,
    );
  }
}
