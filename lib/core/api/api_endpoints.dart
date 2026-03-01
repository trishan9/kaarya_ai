import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static const bool isPhysicalDevice = true;
  static const String _ipAddress = '192.168.1.73';
  static const int _port = 3000;

  // Base URLs
  static String get _host {
    if (isPhysicalDevice) return _ipAddress;
    if (kIsWeb || Platform.isIOS) return 'localhost';
    if (Platform.isAndroid) return '10.0.2.2';
    return 'localhost';
  }

  static String get serverUrl => 'http://$_host:$_port';
  static String get baseUrl => '$serverUrl/api/v1';

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ============ Auth Endpoints ============
  static const String userSignup = '/auth/signup';
  static const String userLogin = '/auth/login';
  static const String me = '/auth/me';
  static const String updateProfile = '/auth/update-me';
  static const String changePassword = '/auth/change-password';
  static const String requestPasswordReset = '/auth/password-reset/request';
  static const String verifyPasswordResetOtp = '/auth/password-reset/verify';
  static const String confirmPasswordReset = '/auth/password-reset/confirm';
  static const String linkedAccounts = '/auth/oauth/accounts';
  static String oauthLinkAuthorize(String provider) =>
      '/auth/oauth/$provider/link/authorize';
  static const String oauthExchange = '/auth/oauth/exchange';
  static const String oauthLinkComplete = '/auth/oauth/link/complete';
  static String oauthUnlink(String provider) => '/auth/oauth/$provider/unlink';
  static const String uploadCertification =
      '/auth/candidate-profile/certifications/upload';

  // ============ User Endpoints ============
  static const String user = '/users';
  static String userById(String id) => '/users/$id';

  // ============ Jobs Endpoints ============
  static const String jobs = '/jobs';
  static String jobById(String id) => '/jobs/$id';
  static String jobView(String id) => '/jobs/$id/view';
  static String jobMetrics(String id) => '/jobs/$id/metrics';

  // ============ Applications Endpoints ============
  static const String myApplications = '/applications/me';
  static const String myApplicationsSummary = '/applications/me/summary';
  static String myApplicationByJob(String jobId) =>
      '/applications/job/$jobId/me';
  static String applyToJob(String jobId) => '/applications/jobs/$jobId';
  static String jobApplications(String jobId) => '/applications/jobs/$jobId';
  static String updateApplication(String jobId, String applicationId) =>
      '/applications/jobs/$jobId/$applicationId';
  static String updateResumeActivity(String jobId, String applicationId) =>
      '/applications/jobs/$jobId/$applicationId/resume-activity';
  static const String myResumes = '/applications/resumes/me';
  static String deleteResume(String resumeId) =>
      '/applications/resumes/$resumeId';

  // ============ Interviews Endpoints ============
  static const String interviews = '/interviews';
  static String interviewById(String id) => '/interviews/$id';
  static String interviewSessions(String id) => '/interviews/$id/sessions';
  static String interviewMySessionsById(String id) =>
      '/interviews/$id/sessions/me';
  static String completeInterviewSession(
    String interviewId,
    String sessionId,
  ) => '/interviews/$interviewId/sessions/$sessionId/complete';
  static String interviewSessionFeedback(String sessionId) =>
      '/interviews/sessions/$sessionId/feedback';
  static String interviewAnalytics(String id) => '/interviews/$id/analytics';
  static const String vapiCreationConfig = '/interviews/vapi/creation-config';

  // ============ Bookmarks Endpoints ============
  static const String myBookmarks = '/bookmarks/me';
  static String bookmarkJob(String jobId) => '/bookmarks/jobs/$jobId';
  static String bookmarkInterview(String interviewId) =>
      '/bookmarks/interviews/$interviewId';

  // ============ Leaderboard Endpoints ============
  static const String leaderboard = '/leaderboard';

  // ============ Companies Endpoints ============
  static const String companies = '/companies';
  static String companyById(String id) => '/companies/$id';
  static const String myCompany = '/companies/me';
  static const String recruiterWorkspaces = '/companies/workspaces/me';
  static const String joinCompanyByCode = '/companies/join-by-code';
  static String companyResetInviteCode(String id) =>
      '/companies/$id/invite-code/reset';
  static String companyRecruiters(String id) => '/companies/$id/recruiters';
  static String companyInviteRecruiter(String id) => '/companies/$id/invites';
  static String removeRecruiter(String companyId, String recruiterId) =>
      '/companies/$companyId/recruiters/$recruiterId';

  // ============ Colleges Endpoints ============
  static const String colleges = '/colleges';
  static String collegeById(String id) => '/colleges/$id';
  static const String myCollege = '/colleges/me';
  static const String collegeWorkspaces = '/colleges/workspaces/me';
  static const String joinCollegeByCode = '/colleges/join-by-code';
  static String collegeResetInviteCode(String id) =>
      '/colleges/$id/invite-code/reset';
  static String collegeStudents(String id) => '/colleges/$id/students';
  static String collegeInviteStudent(String id) => '/colleges/$id/invites';
  static String removeStudent(String collegeId, String studentId) =>
      '/colleges/$collegeId/students/$studentId';
  static String collegeMetrics(String id) => '/colleges/$id/metrics';

  // ============ Resume Builder Endpoints ============
  static const String resumeBuilder = '/resume-builder';
  static const String resumeBuilderList = '/resume-builder/list';
  static String resumeBuilderById(String id) => '/resume-builder/$id';
  static String resumeBuilderGeneratePdf(String id) =>
      '/resume-builder/$id/generate-pdf';
  static String resumeBuilderSave(String id) => '/resume-builder/$id/save';
  static const String resumeBuilderAiSummary = '/resume-builder/ai/summary';
  static const String resumeBuilderAiBullets =
      '/resume-builder/ai/experience-bullets';
  static const String resumeBuilderAiSuggestions =
      '/resume-builder/ai/suggestions';
  static const String resumeBuilderAtsScan = '/resume-builder/ats-scan';

  // ============ Resources Endpoints ============
  static const String resources = '/resources';
  static String resourceById(String id) => '/resources/$id';

  // ============ Stream Endpoints ============
  static const String streamConfig = '/stream/config';
  static const String streamChatToken = '/stream/chat-token';
  static const String streamVideoToken = '/stream/video-token';
  static const String streamEnsureChannels = '/stream/ensure-channels';
  static const String streamEnsureChannelWith = '/stream/ensure-channel-with';

  // ============ Payment Endpoints ============
  static const String paymentBillingSummary = '/payments/billing-summary';
  static const String paymentStripeCheckoutSession =
      '/payments/stripe/checkout-session';
  static const String paymentStripeVerifySession =
      '/payments/stripe/verify-session';
  static const String paymentStripePortalSession =
      '/payments/stripe/portal-session';

  // ============ Admin Endpoints ============
  static const String adminUsers = '/admin/users';
  static const String adminUsersAnalytics = '/admin/users/analytics';
  static String adminUserById(String id) => '/admin/users/$id';
}
