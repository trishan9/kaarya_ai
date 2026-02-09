import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:kaarya/features/dashboard/domain/entities/dashboard_overview_entity.dart';
import 'package:kaarya/features/dashboard/domain/repositories/dashboard_repository.dart';

final getOverviewUseCaseProvider = Provider<GetOverviewUseCase>((ref) {
  final dashboardRepository = ref.read(dashboardRepositoryProvider);
  return GetOverviewUseCase(dashboardRepository: dashboardRepository);
});

class GetOverviewUseCase
    implements
        UseCaseWithParams<DashboardOverviewEntity, GetOverviewUseCaseParams> {
  final IDashboardRepository _dashboardRepository;

  GetOverviewUseCase({required IDashboardRepository dashboardRepository})
    : _dashboardRepository = dashboardRepository;

  @override
  Future<Either<Failure, DashboardOverviewEntity>> call(
    GetOverviewUseCaseParams params,
  ) {
    return _dashboardRepository.getOverviewData(monthKey: params.monthKey);
  }
}

class GetOverviewUseCaseParams {
  final String? monthKey;

  const GetOverviewUseCaseParams({this.monthKey});
}
