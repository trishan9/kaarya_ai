import 'package:equatable/equatable.dart';
import 'package:kaarya/features/companies/domain/entities/company_entity.dart';
import 'package:kaarya/features/companies/domain/entities/recruiter_workspace_entity.dart';
import 'package:kaarya/features/companies/domain/entities/workspace_member_entity.dart';

enum CompanyLoadStatus { initial, loading, loaded, error }

class CompanyState extends Equatable {
  static const Object _unset = Object();

  final CompanyLoadStatus companiesStatus;
  final CompanyLoadStatus companyDetailStatus;
  final CompanyLoadStatus recruitersStatus;
  final CompanyLoadStatus workspacesStatus;

  final List<CompanyEntity>? companies;
  final CompanyEntity? companyDetail;
  final List<WorkspaceMemberEntity>? recruiters;
  final List<RecruiterWorkspaceEntity>? workspaces;

  final String? companiesErrorMessage;
  final String? companyDetailErrorMessage;
  final String? recruitersErrorMessage;
  final String? workspacesErrorMessage;

  const CompanyState({
    this.companiesStatus = CompanyLoadStatus.initial,
    this.companyDetailStatus = CompanyLoadStatus.initial,
    this.recruitersStatus = CompanyLoadStatus.initial,
    this.workspacesStatus = CompanyLoadStatus.initial,
    this.companies,
    this.companyDetail,
    this.recruiters,
    this.workspaces,
    this.companiesErrorMessage,
    this.companyDetailErrorMessage,
    this.recruitersErrorMessage,
    this.workspacesErrorMessage,
  });

  CompanyState copyWith({
    CompanyLoadStatus? companiesStatus,
    CompanyLoadStatus? companyDetailStatus,
    CompanyLoadStatus? recruitersStatus,
    CompanyLoadStatus? workspacesStatus,
    Object? companies = _unset,
    Object? companyDetail = _unset,
    Object? recruiters = _unset,
    Object? workspaces = _unset,
    Object? companiesErrorMessage = _unset,
    Object? companyDetailErrorMessage = _unset,
    Object? recruitersErrorMessage = _unset,
    Object? workspacesErrorMessage = _unset,
  }) {
    return CompanyState(
      companiesStatus: companiesStatus ?? this.companiesStatus,
      companyDetailStatus: companyDetailStatus ?? this.companyDetailStatus,
      recruitersStatus: recruitersStatus ?? this.recruitersStatus,
      workspacesStatus: workspacesStatus ?? this.workspacesStatus,
      companies: companies == _unset
          ? this.companies
          : companies as List<CompanyEntity>?,
      companyDetail: companyDetail == _unset
          ? this.companyDetail
          : companyDetail as CompanyEntity?,
      recruiters: recruiters == _unset
          ? this.recruiters
          : recruiters as List<WorkspaceMemberEntity>?,
      workspaces: workspaces == _unset
          ? this.workspaces
          : workspaces as List<RecruiterWorkspaceEntity>?,
      companiesErrorMessage: companiesErrorMessage == _unset
          ? this.companiesErrorMessage
          : companiesErrorMessage as String?,
      companyDetailErrorMessage: companyDetailErrorMessage == _unset
          ? this.companyDetailErrorMessage
          : companyDetailErrorMessage as String?,
      recruitersErrorMessage: recruitersErrorMessage == _unset
          ? this.recruitersErrorMessage
          : recruitersErrorMessage as String?,
      workspacesErrorMessage: workspacesErrorMessage == _unset
          ? this.workspacesErrorMessage
          : workspacesErrorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    companiesStatus,
    companyDetailStatus,
    recruitersStatus,
    workspacesStatus,
    companies,
    companyDetail,
    recruiters,
    workspaces,
    companiesErrorMessage,
    companyDetailErrorMessage,
    recruitersErrorMessage,
    workspacesErrorMessage,
  ];
}
