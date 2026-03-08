import 'package:dartz/dartz.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/dashboard/domain/entities/dashboard_overview_entity.dart';

abstract interface class IDashboardRepository {
  Future<Either<Failure, DashboardOverviewEntity>> getOverviewData({
    String? monthKey,
  });

  Future<DashboardOverviewEntity?> getOverviewFromCache({String? monthKey});

  Future<Either<Failure, ProfilePreferences>> getProfilePreferences();
}

class ProfilePreferences {
  final String? defaultResumeId;
  final List<String> portfolioLinks;
  final String? linkedinUrl;
  final String? githubUrl;
  final String? portfolioUrl;
  const ProfilePreferences({
    this.defaultResumeId,
    this.portfolioLinks = const [],
    this.linkedinUrl,
    this.githubUrl,
    this.portfolioUrl,
  });
}
