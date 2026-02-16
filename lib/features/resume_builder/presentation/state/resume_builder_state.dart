import 'package:equatable/equatable.dart';
import 'package:kaarya/features/resume_builder/domain/entities/ats_scan_result_entity.dart';
import 'package:kaarya/features/resume_builder/domain/entities/resume_draft_entity.dart';

enum ResumeBuilderLoadStatus { initial, loading, loaded, error }

class ResumeBuilderState extends Equatable {
  static const Object _unset = Object();

  final ResumeBuilderLoadStatus draftsListStatus;
  final ResumeBuilderLoadStatus draftDetailStatus;
  final ResumeBuilderLoadStatus createDraftStatus;
  final ResumeBuilderLoadStatus updateDraftStatus;
  final ResumeBuilderLoadStatus deleteDraftStatus;
  final ResumeBuilderLoadStatus generatePdfStatus;
  final ResumeBuilderLoadStatus saveResumeStatus;
  final ResumeBuilderLoadStatus aiSummaryStatus;
  final ResumeBuilderLoadStatus experienceBulletsStatus;
  final ResumeBuilderLoadStatus aiSuggestionsStatus;
  final ResumeBuilderLoadStatus atsScanStatus;

  final ResumeDraftsListEntity? draftsListData;
  final ResumeDraftEntity? draftDetailData;
  final GeneratePdfResultEntity? generatePdfData;
  final AiSummaryResultEntity? aiSummaryData;
  final ExperienceBulletsResultEntity? experienceBulletsData;
  final AiSuggestionsResultEntity? aiSuggestionsData;
  final AtsScanResultEntity? atsScanData;

  final String? draftsListErrorMessage;
  final String? draftDetailErrorMessage;
  final String? createDraftErrorMessage;
  final String? updateDraftErrorMessage;
  final String? deleteDraftErrorMessage;
  final String? generatePdfErrorMessage;
  final String? saveResumeErrorMessage;
  final String? aiSummaryErrorMessage;
  final String? experienceBulletsErrorMessage;
  final String? aiSuggestionsErrorMessage;
  final String? atsScanErrorMessage;

  final int currentPage;
  final int pageSize;

  const ResumeBuilderState({
    this.draftsListStatus = ResumeBuilderLoadStatus.initial,
    this.draftDetailStatus = ResumeBuilderLoadStatus.initial,
    this.createDraftStatus = ResumeBuilderLoadStatus.initial,
    this.updateDraftStatus = ResumeBuilderLoadStatus.initial,
    this.deleteDraftStatus = ResumeBuilderLoadStatus.initial,
    this.generatePdfStatus = ResumeBuilderLoadStatus.initial,
    this.saveResumeStatus = ResumeBuilderLoadStatus.initial,
    this.aiSummaryStatus = ResumeBuilderLoadStatus.initial,
    this.experienceBulletsStatus = ResumeBuilderLoadStatus.initial,
    this.aiSuggestionsStatus = ResumeBuilderLoadStatus.initial,
    this.atsScanStatus = ResumeBuilderLoadStatus.initial,
    this.draftsListData,
    this.draftDetailData,
    this.generatePdfData,
    this.aiSummaryData,
    this.experienceBulletsData,
    this.aiSuggestionsData,
    this.atsScanData,
    this.draftsListErrorMessage,
    this.draftDetailErrorMessage,
    this.createDraftErrorMessage,
    this.updateDraftErrorMessage,
    this.deleteDraftErrorMessage,
    this.generatePdfErrorMessage,
    this.saveResumeErrorMessage,
    this.aiSummaryErrorMessage,
    this.experienceBulletsErrorMessage,
    this.aiSuggestionsErrorMessage,
    this.atsScanErrorMessage,
    this.currentPage = 1,
    this.pageSize = 20,
  });

  ResumeBuilderState copyWith({
    ResumeBuilderLoadStatus? draftsListStatus,
    ResumeBuilderLoadStatus? draftDetailStatus,
    ResumeBuilderLoadStatus? createDraftStatus,
    ResumeBuilderLoadStatus? updateDraftStatus,
    ResumeBuilderLoadStatus? deleteDraftStatus,
    ResumeBuilderLoadStatus? generatePdfStatus,
    ResumeBuilderLoadStatus? saveResumeStatus,
    ResumeBuilderLoadStatus? aiSummaryStatus,
    ResumeBuilderLoadStatus? experienceBulletsStatus,
    ResumeBuilderLoadStatus? aiSuggestionsStatus,
    ResumeBuilderLoadStatus? atsScanStatus,
    Object? draftsListData = _unset,
    Object? draftDetailData = _unset,
    Object? generatePdfData = _unset,
    Object? aiSummaryData = _unset,
    Object? experienceBulletsData = _unset,
    Object? aiSuggestionsData = _unset,
    Object? atsScanData = _unset,
    Object? draftsListErrorMessage = _unset,
    Object? draftDetailErrorMessage = _unset,
    Object? createDraftErrorMessage = _unset,
    Object? updateDraftErrorMessage = _unset,
    Object? deleteDraftErrorMessage = _unset,
    Object? generatePdfErrorMessage = _unset,
    Object? saveResumeErrorMessage = _unset,
    Object? aiSummaryErrorMessage = _unset,
    Object? experienceBulletsErrorMessage = _unset,
    Object? aiSuggestionsErrorMessage = _unset,
    Object? atsScanErrorMessage = _unset,
    int? currentPage,
    int? pageSize,
  }) {
    return ResumeBuilderState(
      draftsListStatus: draftsListStatus ?? this.draftsListStatus,
      draftDetailStatus: draftDetailStatus ?? this.draftDetailStatus,
      createDraftStatus: createDraftStatus ?? this.createDraftStatus,
      updateDraftStatus: updateDraftStatus ?? this.updateDraftStatus,
      deleteDraftStatus: deleteDraftStatus ?? this.deleteDraftStatus,
      generatePdfStatus: generatePdfStatus ?? this.generatePdfStatus,
      saveResumeStatus: saveResumeStatus ?? this.saveResumeStatus,
      aiSummaryStatus: aiSummaryStatus ?? this.aiSummaryStatus,
      experienceBulletsStatus:
          experienceBulletsStatus ?? this.experienceBulletsStatus,
      aiSuggestionsStatus: aiSuggestionsStatus ?? this.aiSuggestionsStatus,
      atsScanStatus: atsScanStatus ?? this.atsScanStatus,
      draftsListData: draftsListData == _unset
          ? this.draftsListData
          : draftsListData as ResumeDraftsListEntity?,
      draftDetailData: draftDetailData == _unset
          ? this.draftDetailData
          : draftDetailData as ResumeDraftEntity?,
      generatePdfData: generatePdfData == _unset
          ? this.generatePdfData
          : generatePdfData as GeneratePdfResultEntity?,
      aiSummaryData: aiSummaryData == _unset
          ? this.aiSummaryData
          : aiSummaryData as AiSummaryResultEntity?,
      experienceBulletsData: experienceBulletsData == _unset
          ? this.experienceBulletsData
          : experienceBulletsData as ExperienceBulletsResultEntity?,
      aiSuggestionsData: aiSuggestionsData == _unset
          ? this.aiSuggestionsData
          : aiSuggestionsData as AiSuggestionsResultEntity?,
      atsScanData: atsScanData == _unset
          ? this.atsScanData
          : atsScanData as AtsScanResultEntity?,
      draftsListErrorMessage: draftsListErrorMessage == _unset
          ? this.draftsListErrorMessage
          : draftsListErrorMessage as String?,
      draftDetailErrorMessage: draftDetailErrorMessage == _unset
          ? this.draftDetailErrorMessage
          : draftDetailErrorMessage as String?,
      createDraftErrorMessage: createDraftErrorMessage == _unset
          ? this.createDraftErrorMessage
          : createDraftErrorMessage as String?,
      updateDraftErrorMessage: updateDraftErrorMessage == _unset
          ? this.updateDraftErrorMessage
          : updateDraftErrorMessage as String?,
      deleteDraftErrorMessage: deleteDraftErrorMessage == _unset
          ? this.deleteDraftErrorMessage
          : deleteDraftErrorMessage as String?,
      generatePdfErrorMessage: generatePdfErrorMessage == _unset
          ? this.generatePdfErrorMessage
          : generatePdfErrorMessage as String?,
      saveResumeErrorMessage: saveResumeErrorMessage == _unset
          ? this.saveResumeErrorMessage
          : saveResumeErrorMessage as String?,
      aiSummaryErrorMessage: aiSummaryErrorMessage == _unset
          ? this.aiSummaryErrorMessage
          : aiSummaryErrorMessage as String?,
      experienceBulletsErrorMessage: experienceBulletsErrorMessage == _unset
          ? this.experienceBulletsErrorMessage
          : experienceBulletsErrorMessage as String?,
      aiSuggestionsErrorMessage: aiSuggestionsErrorMessage == _unset
          ? this.aiSuggestionsErrorMessage
          : aiSuggestionsErrorMessage as String?,
      atsScanErrorMessage: atsScanErrorMessage == _unset
          ? this.atsScanErrorMessage
          : atsScanErrorMessage as String?,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props => [
    draftsListStatus,
    draftDetailStatus,
    createDraftStatus,
    updateDraftStatus,
    deleteDraftStatus,
    generatePdfStatus,
    saveResumeStatus,
    aiSummaryStatus,
    experienceBulletsStatus,
    aiSuggestionsStatus,
    atsScanStatus,
    draftsListData,
    draftDetailData,
    generatePdfData,
    aiSummaryData,
    experienceBulletsData,
    aiSuggestionsData,
    atsScanData,
    draftsListErrorMessage,
    draftDetailErrorMessage,
    createDraftErrorMessage,
    updateDraftErrorMessage,
    deleteDraftErrorMessage,
    generatePdfErrorMessage,
    saveResumeErrorMessage,
    aiSummaryErrorMessage,
    experienceBulletsErrorMessage,
    aiSuggestionsErrorMessage,
    atsScanErrorMessage,
    currentPage,
    pageSize,
  ];
}
