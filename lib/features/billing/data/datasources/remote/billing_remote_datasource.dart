import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/api/api_client.dart';
import 'package:kaarya/core/api/api_endpoints.dart';
import 'package:kaarya/core/utils/json_parse_helpers.dart';
import 'package:kaarya/features/billing/data/datasources/billing_datasource.dart';
import 'package:kaarya/features/billing/data/models/billing_api_model.dart';

final billingRemoteDatasourceProvider = Provider<IBillingRemoteDataSource>((
  ref,
) {
  return BillingRemoteDataSource(apiClient: ref.read(apiClientProvider));
});

class BillingRemoteDataSource implements IBillingRemoteDataSource {
  BillingRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<BillingSummaryApiModel> getBillingSummary() async {
    final response = await _apiClient.get(ApiEndpoints.paymentBillingSummary);
    return BillingSummaryApiModel.fromJson(_extractDataMap(response));
  }

  @override
  Future<StripeCheckoutSessionApiModel> createStripeCheckoutSession({
    required String successPath,
    required String cancelPath,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.paymentStripeCheckoutSession,
      data: {'successPath': successPath, 'cancelPath': cancelPath},
    );
    return StripeCheckoutSessionApiModel.fromJson(_extractDataMap(response));
  }

  @override
  Future<StripePortalSessionApiModel> createStripePortalSession({
    required String returnPath,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.paymentStripePortalSession,
      data: {'returnPath': returnPath},
    );
    return StripePortalSessionApiModel.fromJson(_extractDataMap(response));
  }

  @override
  Future<StripeCheckoutVerificationApiModel> verifyStripeCheckoutSession(
    String sessionId,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.paymentStripeVerifySession,
      data: {'sessionId': sessionId},
    );
    return StripeCheckoutVerificationApiModel.fromJson(
      _extractDataMap(response),
    );
  }

  Map<String, dynamic> _extractDataMap(Response response) {
    final body = response.data;
    if (body is! Map) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Invalid response payload.',
      );
    }

    final normalized = jsonCastMap(body);
    if (normalized['success'] != true) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: jsonNullableString(normalized['message']) ?? 'Request failed.',
      );
    }

    final data = normalized['data'];
    if (data is Map) {
      return jsonCastMap(data);
    }

    return <String, dynamic>{};
  }
}
