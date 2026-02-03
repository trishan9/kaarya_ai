import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:kaarya/core/constants/hive_table_constant.dart';
import 'package:kaarya/features/applications/data/models/application_hive_model.dart';
import 'package:kaarya/features/applications/data/models/resume_hive_model.dart';
import 'package:kaarya/features/auth/data/models/auth_hive_model.dart';
import 'package:kaarya/features/bookmarks/data/models/bookmark_hive_model.dart';
import 'package:kaarya/features/colleges/data/models/college_hive_model.dart';
import 'package:kaarya/features/companies/data/models/company_hive_model.dart';
import 'package:kaarya/features/dashboard/data/models/dashboard_overview_hive_model.dart';
import 'package:kaarya/features/interviews/data/models/interview_hive_model.dart';
import 'package:kaarya/features/jobs/data/models/job_hive_model.dart';
import 'package:kaarya/features/leaderboard/data/models/leaderboard_hive_model.dart';
import 'package:kaarya/features/resources/data/models/resource_course_hive_model.dart';
import 'package:kaarya/features/resume_builder/data/models/resume_draft_hive_model.dart';
import 'package:path_provider/path_provider.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstant.dbName}';
    Hive.init(path);

    _registerAdapters();
    await _openBoxes();
  }

  void _registerAdapters() {
    void reg<T>(int id, TypeAdapter<T> adapter) {
      if (!Hive.isAdapterRegistered(id)) Hive.registerAdapter(adapter);
    }

    reg(HiveTableConstant.userTypeId, AuthHiveModelAdapter());
    reg(HiveTableConstant.jobHiveTypeId, JobHiveModelAdapter());
    reg(HiveTableConstant.jobsSectionHiveTypeId, JobsSectionHiveModelAdapter());
    reg(HiveTableConstant.interviewHiveTypeId, InterviewHiveModelAdapter());
    reg(
      HiveTableConstant.interviewsSectionHiveTypeId,
      InterviewsSectionHiveModelAdapter(),
    );
    reg(HiveTableConstant.applicationHiveTypeId, ApplicationHiveModelAdapter());
    reg(HiveTableConstant.resumeHiveTypeId, ResumeHiveModelAdapter());
    reg(HiveTableConstant.jobBookmarkHiveTypeId, JobBookmarkHiveModelAdapter());
    reg(
      HiveTableConstant.interviewBookmarkHiveTypeId,
      InterviewBookmarkHiveModelAdapter(),
    );
    reg(HiveTableConstant.bookmarksHiveTypeId, BookmarksHiveModelAdapter());
    reg(
      HiveTableConstant.leaderboardEntryHiveTypeId,
      LeaderboardEntryHiveModelAdapter(),
    );
    reg(HiveTableConstant.leaderboardHiveTypeId, LeaderboardHiveModelAdapter());
    reg(
      HiveTableConstant.dashboardOverviewHiveTypeId,
      DashboardOverviewHiveModelAdapter(),
    );
    reg(HiveTableConstant.companyHiveTypeId, CompanyHiveModelAdapter());
    reg(HiveTableConstant.collegeHiveTypeId, CollegeHiveModelAdapter());
    reg(
      HiveTableConstant.resourceCourseHiveTypeId,
      ResourceCourseHiveModelAdapter(),
    );
    reg(HiveTableConstant.resumeDraftHiveTypeId, ResumeDraftHiveModelAdapter());
  }

  Future<void> _openBoxes() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.userTable);
    await Hive.openBox<JobsSectionHiveModel>(
      HiveTableConstant.jobsSectionTable,
    );
    await Hive.openBox<InterviewsSectionHiveModel>(
      HiveTableConstant.interviewsSectionTable,
    );
    await Hive.openBox<ApplicationHiveModel>(
      HiveTableConstant.applicationsTable,
    );
    await Hive.openBox<ResumeHiveModel>(HiveTableConstant.resumesTable);
    await Hive.openBox<BookmarksHiveModel>(HiveTableConstant.bookmarksTable);
    await Hive.openBox<LeaderboardHiveModel>(
      HiveTableConstant.leaderboardTable,
    );
    await Hive.openBox<DashboardOverviewHiveModel>(
      HiveTableConstant.overviewTable,
    );
    await Hive.openBox<CompanyHiveModel>(HiveTableConstant.companiesTable);
    await Hive.openBox<CollegeHiveModel>(HiveTableConstant.collegesTable);
    await Hive.openBox<ResourceCourseHiveModel>(
      HiveTableConstant.resourcesTable,
    );
    await Hive.openBox<ResumeDraftHiveModel>(
      HiveTableConstant.resumeBuilderTable,
    );
    // Legacy box kept for backward compat
    await Hive.openBox<String>(HiveTableConstant.dashboardJobsSectionTable);
  }

  Future<void> close() async {
    await Hive.close();
  }

  // ====================Authentication=====================
  Box<AuthHiveModel> get authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstant.userTable);

  Future<AuthHiveModel> registerUser(AuthHiveModel user) async {
    await authBox.put(user.authId, user);
    return user;
  }

  AuthHiveModel? loginUser(String email, String password) {
    try {
      return authBox.values.firstWhere(
        (user) => user.email == email && user.password == password,
      );
    } catch (e) {
      return null;
    }
  }

  AuthHiveModel? getUserById(String authId) => authBox.get(authId);

  AuthHiveModel? getUserByEmail(String email) {
    try {
      return authBox.values.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteUser(String authId) async {
    await authBox.delete(authId);
  }

  // ====================Jobs Section=====================
  Box<JobsSectionHiveModel> get _jobsSectionBox =>
      Hive.box<JobsSectionHiveModel>(HiveTableConstant.jobsSectionTable);

  Future<void> saveJobsSection(JobsSectionHiveModel model) async {
    await _jobsSectionBox.put('default', model);
  }

  JobsSectionHiveModel? getJobsSection() => _jobsSectionBox.get('default');

  // ====================Interviews Section=====================
  Box<InterviewsSectionHiveModel> get _interviewsSectionBox =>
      Hive.box<InterviewsSectionHiveModel>(
        HiveTableConstant.interviewsSectionTable,
      );

  Future<void> saveInterviewsSection(InterviewsSectionHiveModel model) async {
    await _interviewsSectionBox.put('default', model);
  }

  InterviewsSectionHiveModel? getInterviewsSection() =>
      _interviewsSectionBox.get('default');

  // ====================Applications=====================
  Box<ApplicationHiveModel> get _applicationsBox =>
      Hive.box<ApplicationHiveModel>(HiveTableConstant.applicationsTable);

  Future<void> saveMyApplications(List<ApplicationHiveModel> models) async {
    await _applicationsBox.clear();
    await _applicationsBox.addAll(models);
  }

  List<ApplicationHiveModel> getMyApplications() =>
      _applicationsBox.values.toList();

  // ====================Resumes=====================
  Box<ResumeHiveModel> get _resumesBox =>
      Hive.box<ResumeHiveModel>(HiveTableConstant.resumesTable);

  Future<void> saveResumes(List<ResumeHiveModel> models) async {
    await _resumesBox.clear();
    await _resumesBox.addAll(models);
  }

  List<ResumeHiveModel> listMyResumes() => _resumesBox.values.toList();

  // ====================Bookmarks=====================
  Box<BookmarksHiveModel> get _bookmarksBox =>
      Hive.box<BookmarksHiveModel>(HiveTableConstant.bookmarksTable);

  Future<void> saveMyBookmarks(BookmarksHiveModel model) async {
    await _bookmarksBox.put('default', model);
  }

  BookmarksHiveModel? getMyBookmarks() => _bookmarksBox.get('default');

  // ====================Leaderboard=====================
  Box<LeaderboardHiveModel> get _leaderboardBox =>
      Hive.box<LeaderboardHiveModel>(HiveTableConstant.leaderboardTable);

  Future<void> saveLeaderboard(LeaderboardHiveModel model) async {
    await _leaderboardBox.put('default', model);
  }

  LeaderboardHiveModel? getLeaderboard() => _leaderboardBox.get('default');

  // ====================Dashboard Overview=====================
  Box<DashboardOverviewHiveModel> get _overviewBox =>
      Hive.box<DashboardOverviewHiveModel>(HiveTableConstant.overviewTable);

  Future<void> saveOverviewData(DashboardOverviewHiveModel model) async {
    await _overviewBox.put(model.monthKey, model);
  }

  DashboardOverviewHiveModel? getOverviewData(String monthKey) =>
      _overviewBox.get(monthKey.isEmpty ? 'default' : monthKey);

  // ====================Companies=====================
  Box<CompanyHiveModel> get _companiesBox =>
      Hive.box<CompanyHiveModel>(HiveTableConstant.companiesTable);

  Future<void> saveCompanies(List<CompanyHiveModel> models) async {
    await _companiesBox.putAll({for (final m in models) m.id: m});
  }

  List<CompanyHiveModel> listCompanies() => _companiesBox.values.toList();

  Future<void> saveCompany(CompanyHiveModel model) async {
    await _companiesBox.put(model.id, model);
  }

  CompanyHiveModel? getCompanyById(String id) => _companiesBox.get(id);

  Future<void> clearCompanies() async => _companiesBox.clear();

  // ====================Colleges=====================
  Box<CollegeHiveModel> get _collegesBox =>
      Hive.box<CollegeHiveModel>(HiveTableConstant.collegesTable);

  Future<void> saveColleges(List<CollegeHiveModel> models) async {
    await _collegesBox.putAll({for (final m in models) m.id: m});
  }

  List<CollegeHiveModel> listColleges() => _collegesBox.values.toList();

  Future<void> saveCollege(CollegeHiveModel model) async {
    await _collegesBox.put(model.id, model);
  }

  CollegeHiveModel? getCollegeById(String id) => _collegesBox.get(id);

  Future<void> clearColleges() async => _collegesBox.clear();

  // ====================Resources (Courses)=====================
  Box<ResourceCourseHiveModel> get _resourcesBox =>
      Hive.box<ResourceCourseHiveModel>(HiveTableConstant.resourcesTable);

  Future<void> saveCoursesList(List<ResourceCourseHiveModel> models) async {
    await _resourcesBox.putAll({for (final m in models) m.id: m});
  }

  List<ResourceCourseHiveModel> listCourses() => _resourcesBox.values.toList();

  Future<void> saveCourse(ResourceCourseHiveModel model) async {
    await _resourcesBox.put(model.id, model);
  }

  ResourceCourseHiveModel? getCourseById(String id) => _resourcesBox.get(id);

  // ====================Resume Builder (Drafts)=====================
  Box<ResumeDraftHiveModel> get _resumeBuilderBox =>
      Hive.box<ResumeDraftHiveModel>(HiveTableConstant.resumeBuilderTable);

  Future<void> saveDraftsList(List<ResumeDraftHiveModel> models) async {
    await _resumeBuilderBox.putAll({for (final m in models) m.id: m});
  }

  List<ResumeDraftHiveModel> listDrafts() => _resumeBuilderBox.values.toList();

  Future<void> saveDraft(ResumeDraftHiveModel model) async {
    await _resumeBuilderBox.put(model.id, model);
  }

  ResumeDraftHiveModel? getDraftById(String id) => _resumeBuilderBox.get(id);

  Future<void> deleteDraft(String id) async {
    await _resumeBuilderBox.delete(id);
  }

  Box<String> get _dashboardJobsSectionBox =>
      Hive.box<String>(HiveTableConstant.dashboardJobsSectionTable);

  Future<void> saveDashboardJobsSection(String jsonPayload) async {
    await _dashboardJobsSectionBox.put('default', jsonPayload);
  }

  String? getDashboardJobsSection() => _dashboardJobsSectionBox.get('default');
}
