import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/services/connectivity/network_info.dart';
import 'package:kaarya/features/companies/data/datasources/company_datasource.dart';
import 'package:kaarya/features/companies/data/datasources/local/company_local_datasource.dart';
import 'package:kaarya/features/companies/data/datasources/remote/company_remote_datasource.dart';
import 'package:kaarya/features/companies/data/models/company_hive_model.dart';
import 'package:kaarya/features/companies/domain/entities/company_entity.dart';
import 'package:kaarya/features/companies/domain/entities/recruiter_workspace_entity.dart';
import 'package:kaarya/features/companies/domain/entities/workspace_member_entity.dart';
import 'package:kaarya/features/companies/domain/repositories/company_repository.dart';

final companyRepositoryProvider = Provider<ICompanyRepository>((ref) {
  return CompanyRepository(
    remoteDatasource: ref.read(companyRemoteDatasourceProvider),
    localDatasource: ref.read(companyLocalDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class CompanyRepository implements ICompanyRepository {
  final ICompanyRemoteDataSource _remoteDatasource;
  final ICompanyLocalDataSource _localDatasource;
  final NetworkInfo _networkInfo;

  CompanyRepository({
    required ICompanyRemoteDataSource remoteDatasource,
    required ICompanyLocalDataSource localDatasource,
    required NetworkInfo networkInfo,
  }) : _remoteDatasource = remoteDatasource,
       _localDatasource = localDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<CompanyEntity>>> listCompanies({
    int page = 1,
    int size = 20,
    String? search,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remoteDatasource.listCompanies(
          page: page,
          size: size,
          search: search,
        );
        await _localDatasource.saveCompanies(
          remote.map(CompanyHiveModel.fromApiModel).toList(),
        );
        return Right(remote.map((e) => e.toEntity()).toList());
      } on DioException catch (e) {
        final cached = await _localDatasource.listCompanies();
        if (cached.isNotEmpty) {
          return Right(cached.map((e) => e.toApiModel().toEntity()).toList());
        }
        return Left(
          _mapDioException(e, fallbackMessage: 'Failed to load companies.'),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    }

    final cached = await _localDatasource.listCompanies();
    if (cached.isNotEmpty) {
      return Right(cached.map((e) => e.toApiModel().toEntity()).toList());
    }
    return const Left(
      NetworkFailure(
        message: 'No internet connection and no cached companies data.',
      ),
    );
  }

  @override
  Future<Either<Failure, CompanyEntity>> getCompanyById(
    String companyId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remoteDatasource.getCompanyById(companyId);
        await _localDatasource.saveCompany(
          CompanyHiveModel.fromApiModel(remote),
        );
        return Right(remote.toEntity());
      } on DioException catch (e) {
        final cached = await _localDatasource.getCompanyById(companyId);
        if (cached != null) {
          return Right(cached.toApiModel().toEntity());
        }
        return Left(
          _mapDioException(
            e,
            fallbackMessage: 'Failed to load company details.',
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    }

    final cached = await _localDatasource.getCompanyById(companyId);
    if (cached != null) {
      return Right(cached.toApiModel().toEntity());
    }
    return const Left(
      NetworkFailure(
        message: 'No internet connection and no cached company data.',
      ),
    );
  }

  @override
  Future<Either<Failure, CompanyEntity>> createCompany({
    required String name,
    required String industry,
    required String location,
    String? logoPath,
    required String designation,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection to create company.'),
      );
    }

    try {
      final result = await _remoteDatasource.createCompany(
        name: name,
        industry: industry,
        location: location,
        logoPath: logoPath,
        designation: designation,
      );
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(
        _mapDioException(e, fallbackMessage: 'Failed to create company.'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CompanyEntity>> updateCompany({
    required String companyId,
    required Map<String, dynamic> fields,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection to update company.'),
      );
    }

    try {
      final result = await _remoteDatasource.updateCompany(
        companyId: companyId,
        fields: fields,
      );
      await _localDatasource.saveCompany(CompanyHiveModel.fromApiModel(result));
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(
        _mapDioException(e, fallbackMessage: 'Failed to update company.'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteCompany(String companyId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection to delete company.'),
      );
    }

    try {
      final result = await _remoteDatasource.deleteCompany(companyId);
      return Right(result);
    } on DioException catch (e) {
      return Left(
        _mapDioException(e, fallbackMessage: 'Failed to delete company.'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CompanyEntity>> joinByCode({
    required String inviteCode,
    required String designation,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection to join company.'),
      );
    }

    try {
      final result = await _remoteDatasource.joinByCode(
        inviteCode: inviteCode,
        designation: designation,
      );
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(
        _mapDioException(
          e,
          fallbackMessage: 'Failed to join company by invite code.',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CompanyEntity>> resetInviteCode(
    String companyId,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection to reset invite code.'),
      );
    }

    try {
      final result = await _remoteDatasource.resetInviteCode(companyId);
      await _localDatasource.saveCompany(CompanyHiveModel.fromApiModel(result));
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(
        _mapDioException(e, fallbackMessage: 'Failed to reset invite code.'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WorkspaceMemberEntity>>> listRecruiters({
    required String companyId,
    int page = 1,
    int size = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection to load recruiters.'),
      );
    }

    try {
      final result = await _remoteDatasource.listRecruiters(
        companyId: companyId,
        page: page,
        size: size,
      );
      return Right(result.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Left(
        _mapDioException(e, fallbackMessage: 'Failed to load recruiters.'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> inviteRecruiter({
    required String companyId,
    required String email,
    required String designation,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection to invite recruiter.'),
      );
    }

    try {
      final result = await _remoteDatasource.inviteRecruiter(
        companyId: companyId,
        email: email,
        designation: designation,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(
        _mapDioException(e, fallbackMessage: 'Failed to invite recruiter.'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> removeRecruiter({
    required String companyId,
    required String recruiterId,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection to remove recruiter.'),
      );
    }

    try {
      final result = await _remoteDatasource.removeRecruiter(
        companyId: companyId,
        recruiterId: recruiterId,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(
        _mapDioException(e, fallbackMessage: 'Failed to remove recruiter.'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RecruiterWorkspaceEntity>>>
  listRecruiterWorkspaces({int page = 1, int size = 20}) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection to load workspaces.'),
      );
    }

    try {
      final remote = await _remoteDatasource.listRecruiterWorkspaces(
        page: page,
        size: size,
      );
      return Right(remote.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Left(
        _mapDioException(e, fallbackMessage: 'Failed to load workspaces.'),
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
