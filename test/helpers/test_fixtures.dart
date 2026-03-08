import 'package:kaarya/features/applications/domain/entities/application_entity.dart';
import 'package:kaarya/features/applications/domain/entities/application_summary_entity.dart';
import 'package:kaarya/features/applications/domain/entities/job_applicant_entity.dart';
import 'package:kaarya/features/applications/domain/entities/resume_entity.dart';
import 'package:kaarya/features/auth/domain/entities/auth_entity.dart';
import 'package:kaarya/features/auth/domain/entities/linked_account_entity.dart';
import 'package:kaarya/features/auth/domain/entities/oauth_provider_status_entity.dart';
import 'package:kaarya/features/billing/domain/entities/billing_summary_entity.dart';
import 'package:kaarya/features/bookmarks/domain/entities/bookmark_entity.dart';
import 'package:kaarya/features/colleges/domain/entities/college_entity.dart';
import 'package:kaarya/features/colleges/domain/entities/college_metrics_entity.dart';
import 'package:kaarya/features/colleges/domain/entities/college_workspace_entity.dart';
import 'package:kaarya/features/colleges/domain/entities/student_member_entity.dart';
import 'package:kaarya/features/companies/domain/entities/company_entity.dart';
import 'package:kaarya/features/companies/domain/entities/recruiter_workspace_entity.dart';
import 'package:kaarya/features/companies/domain/entities/workspace_member_entity.dart';
import 'package:kaarya/features/dashboard/domain/entities/dashboard_overview_entity.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_analytics_entity.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_entity.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_feedback_entity.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_section_entity.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_session_entity.dart';
import 'package:kaarya/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:kaarya/features/jobs/domain/entities/job_entity.dart';
import 'package:kaarya/features/jobs/domain/entities/job_metrics_entity.dart';
import 'package:kaarya/features/jobs/domain/entities/jobs_section_entity.dart';
import 'package:kaarya/features/leaderboard/domain/entities/leaderboard_entity.dart';
import 'package:kaarya/features/resources/domain/entities/resource_course_entity.dart';
import 'package:kaarya/features/resume_builder/domain/entities/ats_scan_result_entity.dart';
import 'package:kaarya/features/resume_builder/domain/entities/resume_draft_entity.dart';

AuthEntity buildAuthEntity({
  String authId = 'auth-1',
  String name = 'Test User',
  String email = 'test@example.com',
  String? password = 'password123',
  String? confirmPassword = 'password123',
  String provider = 'email',
  String role = 'candidate',
  String profilePicture = 'https://example.com/photo.png',
}) {
  return AuthEntity(
    authId: authId,
    name: name,
    email: email,
    password: password,
    confirmPassword: confirmPassword,
    provider: provider,
    role: role,
    profilePicture: profilePicture,
  );
}

OAuthProviderStatusEntity buildOAuthProviderStatus({
  String provider = 'google',
  bool enabled = true,
  String mobileStrategy = 'sdk',
  String? serverClientId = 'server-client-id',
}) {
  return OAuthProviderStatusEntity(
    provider: provider,
    enabled: enabled,
    mobileStrategy: mobileStrategy,
    serverClientId: serverClientId,
  );
}

LinkedAccountEntity buildLinkedAccountEntity({
  String provider = 'google',
  String email = 'linked@example.com',
}) {
  return LinkedAccountEntity(provider: provider, email: email, name: 'Linked');
}

JobEntity buildJobEntity({
  String id = 'job-1',
  String title = 'AI Engineer',
  String status = 'open',
  String workMode = 'remote',
  bool isSaved = false,
  bool hasApplied = false,
  String deadline = '2099-12-31',
  String createdAt = '2026-01-01T00:00:00.000Z',
  int applicationsCount = 12,
  int viewsCount = 120,
  String companyName = 'Kaarya',
}) {
  return JobEntity(
    id: id,
    title: title,
    companyName: companyName,
    companyLogo: 'https://example.com/logo.png',
    location: 'Kathmandu',
    employmentType: 'Full-time',
    engagementType: 'Internship',
    workMode: workMode,
    salaryRange: 'NPR 50,000',
    status: status,
    deadline: deadline,
    createdAt: createdAt,
    applicationsCount: applicationsCount,
    viewsCount: viewsCount,
    isSaved: isSaved,
    hasApplied: hasApplied,
    myApplicationId: hasApplied ? 'app-1' : null,
  );
}

JobsBucketEntity buildJobsBucketEntity() {
  return JobsBucketEntity(
    forYou: [buildJobEntity(id: 'job-1', title: 'AI Engineer')],
    trending: [buildJobEntity(id: 'job-2', title: 'Software Engineer')],
    newThisWeek: [buildJobEntity(id: 'job-3', title: 'Flutter Developer')],
    remote: [buildJobEntity(id: 'job-4', title: 'Remote Engineer')],
    urgent: [buildJobEntity(id: 'job-5', title: 'Urgent Designer')],
  );
}

JobsSectionEntity buildJobsSectionEntity({
  String searchQuery = '',
  String locationQuery = '',
}) {
  return JobsSectionEntity(
    searchQuery: searchQuery,
    locationQuery: locationQuery,
    jobs: buildJobsBucketEntity(),
  );
}

JobDetailEntity buildJobDetailEntity({String id = 'job-1'}) {
  return JobDetailEntity(
    id: id,
    title: 'AI Engineer',
    description: 'Build products',
    companyName: 'Kaarya',
    companyLogo: 'https://example.com/logo.png',
    companyId: 'company-1',
    location: 'Kathmandu',
    employmentType: 'Full-time',
    engagementType: 'Internship',
    workMode: 'remote',
    salaryRange: 'NPR 50,000',
    status: 'open',
    deadline: '2099-12-31',
    createdAt: '2026-01-01T00:00:00.000Z',
    applicationsCount: 12,
    viewsCount: 120,
    isSaved: false,
    hasApplied: false,
    myApplicationId: null,
    level: 'Mid',
    experience: '2 years',
    requirements: const ['Dart', 'Flutter'],
    company: const CompanyDetailEntity(
      id: 'company-1',
      name: 'Kaarya',
      location: 'Kathmandu',
    ),
    similarJobs: [buildJobEntity(id: 'job-9', title: 'Backend Engineer')],
  );
}

JobMetricsEntity buildJobMetricsEntity() {
  return const JobMetricsEntity(
    viewCount: 120,
    applicationsCount: 12,
    uniqueViewers: 80,
    shortlistedCount: 3,
    interviewScheduledCount: 2,
    acceptedCount: 1,
    rejectedCount: 1,
  );
}

InterviewEntity buildInterviewEntity({
  String id = 'interview-1',
  String title = 'Mock Flutter Interview',
  bool isSaved = false,
  bool hasAttempted = false,
  String status = 'published',
}) {
  return InterviewEntity(
    id: id,
    title: title,
    role: 'Flutter Developer',
    interviewType: 'technical',
    status: status,
    source: 'ai',
    companyName: 'Kaarya',
    companyLogo: 'https://example.com/logo.png',
    attemptsCount: 2,
    myLatestScore: 87,
    myLatestSessionId: 'session-1',
    hasAttempted: hasAttempted,
    isSaved: isSaved,
    techStack: const ['Flutter', 'Dart'],
    createdAt: '2026-01-01T00:00:00.000Z',
    updatedAt: '2026-01-02T00:00:00.000Z',
  );
}

InterviewsSectionEntity buildInterviewsSectionEntity() {
  final interview = buildInterviewEntity();
  return InterviewsSectionEntity(
    forYou: [interview],
    trending: [buildInterviewEntity(id: 'interview-2')],
    newThisWeek: [buildInterviewEntity(id: 'interview-3')],
    allTimePopular: [buildInterviewEntity(id: 'interview-4')],
    byYou: [buildInterviewEntity(id: 'interview-5')],
    all: [interview],
    createdByMe: [buildInterviewEntity(id: 'interview-6')],
    takenByMe: [buildInterviewEntity(id: 'interview-7', hasAttempted: true)],
    drafts: [buildInterviewEntity(id: 'interview-8', status: 'draft')],
    averageScore: 83.5,
    lastUpdatedAt: '2026-01-02T00:00:00.000Z',
  );
}

InterviewFeedbackEntity buildInterviewFeedbackEntity() {
  return const InterviewFeedbackEntity(
    sessionId: 'session-1',
    interviewTitle: 'Mock Flutter Interview',
    totalScore: 88,
    finalAssessment: 'Strong performance',
    categoryScores: [
      InterviewCategoryScoreEntity(
        category: 'Communication',
        score: 90,
        feedback: 'Clear answers',
      ),
    ],
    strengths: ['Communication'],
    areasForImprovement: ['System design'],
    interviewId: 'interview-1',
    interviewLevel: 'Mid',
    durationSeconds: 600,
  );
}

InterviewSessionStartEntity buildInterviewSessionStartEntity({
  String? vapiWebToken = 'web-token',
  List<Map<String, dynamic>> questions = const [
    {'question': 'Tell me about yourself'},
  ],
}) {
  return InterviewSessionStartEntity(
    sessionId: 'session-1',
    interviewId: 'interview-1',
    vapiWebToken: vapiWebToken,
    vapiAssistantId: 'assistant-1',
    vapiAssistantConfig: const {'name': 'Assistant'},
    vapiWorkflowId: 'workflow-1',
    vapiVariableValues: const {'candidateName': 'Test User'},
    interviewTitle: 'Mock Flutter Interview',
    interviewRole: 'Flutter Developer',
    questions: questions,
  );
}

InterviewSessionEntity buildInterviewSessionEntity() {
  return const InterviewSessionEntity(
    id: 'session-1',
    interviewId: 'interview-1',
    userId: 'user-1',
    status: 'completed',
    durationSeconds: 600,
    totalScore: 88,
    createdAt: '2026-01-01T00:00:00.000Z',
  );
}

InterviewAnalyticsEntity buildInterviewAnalyticsEntity() {
  return const InterviewAnalyticsEntity(
    totalSessions: 4,
    completionRate: 75,
    averageScore: 84,
    scoreDistribution: [
      InterviewScoreDistributionEntity(range: '80-90', count: 2),
    ],
  );
}

BookmarksListEntity buildBookmarksListEntity() {
  return BookmarksListEntity(
    jobs: [buildJobEntity(id: 'job-1', isSaved: true)],
    interviews: [buildInterviewEntity(id: 'interview-1', isSaved: true)],
    totalSaved: 2,
    bookmarkedJobs: 1,
    savedInterviews: 1,
  );
}

ApplicationEntity buildApplicationEntity({
  String id = 'app-1',
  String status = 'applied',
}) {
  return ApplicationEntity(
    id: id,
    jobId: 'job-1',
    jobTitle: 'AI Engineer',
    companyName: 'Kaarya',
    companyLogo: 'https://example.com/logo.png',
    status: status,
    appliedAt: '2026-01-01T00:00:00.000Z',
    updatedAt: '2026-01-02T00:00:00.000Z',
    nextStep: 'Screening',
    location: 'Kathmandu',
    employmentType: 'Full-time',
    workMode: 'remote',
    salaryRange: 'NPR 50,000',
  );
}

ApplicationsListEntity buildApplicationsListEntity() {
  return ApplicationsListEntity(
    applications: [buildApplicationEntity()],
    totalSubmissions: 1,
    inProgressCount: 1,
    interviewCount: 0,
    acceptedCount: 0,
  );
}

ApplicationSummaryEntity buildApplicationSummaryEntity() {
  return const ApplicationSummaryEntity(
    total: 12,
    delta: 3,
    todayCount: 1,
    monthKey: '2026-03',
    monthLabel: 'March 2026',
    appliedCount: 5,
    reviewingCount: 3,
    shortlistedCount: 1,
    interviewCount: 1,
    acceptedCount: 1,
    rejectedCount: 1,
    withdrawnCount: 0,
  );
}

JobApplicantsListEntity buildJobApplicantsListEntity() {
  return const JobApplicantsListEntity(
    applicants: [
      JobApplicantEntity(
        id: 'applicant-1',
        status: 'applied',
        appliedAt: '2026-01-01T00:00:00.000Z',
        updatedAt: '2026-01-02T00:00:00.000Z',
        candidateName: 'Applicant',
      ),
    ],
    jobId: 'job-1',
  );
}

ResumeEntity buildResumeEntity({String id = 'resume-1'}) {
  return ResumeEntity(
    id: id,
    fileName: 'resume.pdf',
    url: 'https://example.com/resume.pdf',
    uploadedAt: '2026-01-01T00:00:00.000Z',
    atsScore: 82,
  );
}

ResourceCourseEntity buildResourceCourseEntity({String id = 'course-1'}) {
  return ResourceCourseEntity(
    id: id,
    title: 'Flutter Basics',
    description: 'Learn Flutter',
    category: 'mobile',
    difficulty: 'beginner',
    targetRoles: ['Flutter Developer'],
    visibility: 'public',
    source: 'ai',
    generationMode: 'guided',
    chapters: [
      CourseChapterEntity(
        title: 'Introduction',
        sections: [
          ChapterSectionEntity(heading: 'Start', subheadings: ['Install SDK']),
        ],
        videos: [
          ChapterVideoEntity(
            title: 'Intro',
            url: 'https://example.com/video',
            thumbnail: 'https://example.com/thumb.png',
          ),
        ],
        coreConcepts: [
          CoreConceptEntity(
            title: 'Widgets',
            explanation: 'Everything is a widget',
          ),
        ],
        interviewQuestions: [
          InterviewQuestionEntity(
            question: 'What is Flutter?',
            sampleAnswer: 'A UI toolkit',
          ),
        ],
        practicePrompts: ['Build a counter app'],
      ),
    ],
    chaptersCount: 1,
    createdAt: '2026-01-01T00:00:00.000Z',
    updatedAt: '2026-01-02T00:00:00.000Z',
    createdBy: 'user-1',
  );
}

ResourceCoursesListEntity buildResourceCoursesListEntity() {
  return ResourceCoursesListEntity(
    courses: [buildResourceCourseEntity()],
    totalCount: 1,
    page: 1,
    size: 20,
  );
}

ResumeDraftEntity buildResumeDraftEntity({String id = 'draft-1'}) {
  return ResumeDraftEntity(
    id: id,
    title: 'Software Engineer Resume',
    template: 'modern',
    personalInfo: ResumePersonalInfoEntity(
      name: 'Test User',
      email: 'test@example.com',
      phone: '9800000000',
      location: 'Kathmandu',
    ),
    education: [
      ResumeEducationEntity(
        institution: 'TU',
        degree: 'BSc',
        fieldOfStudy: 'CS',
        startDate: '2020',
        endDate: '2024',
      ),
    ],
    experience: [
      ResumeExperienceEntity(
        company: 'Kaarya',
        jobTitle: 'Intern',
        startDate: '2024',
        endDate: '2025',
        isCurrent: false,
        bullets: ['Built features'],
      ),
    ],
    skills: [ResumeSkillEntity(name: 'Flutter')],
    projects: [
      ResumeProjectEntity(name: 'Portfolio', technologies: ['Flutter']),
    ],
    certifications: [ResumeCertificationEntity(name: 'AWS', issuer: 'Amazon')],
    achievements: [ResumeAchievementEntity(title: 'Hackathon Winner')],
    professionalSummary: 'Builder',
    createdAt: '2026-01-01T00:00:00.000Z',
    updatedAt: '2026-01-02T00:00:00.000Z',
  );
}

ResumeDraftsListEntity buildResumeDraftsListEntity() {
  return ResumeDraftsListEntity(
    drafts: [buildResumeDraftEntity()],
    totalCount: 1,
    page: 1,
    size: 20,
  );
}

AtsScanResultEntity buildAtsScanResultEntity() {
  return const AtsScanResultEntity(
    overallScore: 82,
    documentType: 'resume',
    ats: AtsScanCategoryEntity(
      score: 85,
      tips: [
        AtsScanTipEntity(type: 'good', tip: 'Keywords are strong'),
        AtsScanTipEntity(type: 'improve', tip: 'Add Riverpod'),
      ],
    ),
  );
}

BillingSummaryEntity buildBillingSummaryEntity() {
  return BillingSummaryEntity(
    currentPlan: 'free',
    currentPlanLabel: 'Free',
    currentPlanPriceNpr: 0,
    nextPlan: 'pro',
    nextPlanLabel: 'Pro',
    nextPlanPriceNpr: 999,
    canUpgrade: true,
    currency: 'NPR',
    usage: const BillingUsageEntity(
      month: '2026-03',
      interviewsUsed: 1,
      interviewsRemaining: 9,
    ),
    limits: const BillingLimitsEntity(monthlyInterviewLimit: 10),
    plans: const [
      BillingPlanSnapshotEntity(
        id: 'pro',
        label: 'Pro',
        monthlyPriceNpr: 999,
        monthlyInterviewLimit: 100,
      ),
    ],
    invoices: const [
      BillingInvoiceEntity(
        id: 'invoice-1',
        invoiceNumber: 'INV-001',
        transactionUuid: 'txn-1',
        amountNpr: 999,
        currency: 'NPR',
        paymentProvider: 'stripe',
        status: 'paid',
        planFrom: 'free',
        planTo: 'pro',
        issuedAt: null,
        paidAt: null,
      ),
    ],
  );
}

StripeCheckoutSessionEntity buildStripeCheckoutSessionEntity() {
  return const StripeCheckoutSessionEntity(
    sessionId: 'checkout-1',
    checkoutUrl: 'https://example.com/checkout',
    currency: 'NPR',
    amountNpr: 999,
    plan: 'pro',
  );
}

StripePortalSessionEntity buildStripePortalSessionEntity() {
  return const StripePortalSessionEntity(
    portalUrl: 'https://example.com/portal',
  );
}

StripeCheckoutVerificationEntity buildStripeCheckoutVerificationEntity() {
  return const StripeCheckoutVerificationEntity(
    plan: 'pro',
    unlocked: true,
    sessionId: 'checkout-1',
    invoiceNumber: 'INV-001',
    amountNpr: 999,
    currency: 'NPR',
  );
}

CompanyEntity buildCompanyEntity({String id = 'company-1'}) {
  return CompanyEntity(
    id: id,
    name: 'Kaarya',
    industry: 'Software',
    location: 'Kathmandu',
    logo: 'https://example.com/logo.png',
    verifiedStatus: 'verified',
    inviteCode: 'JOIN123',
    recruitersCount: 4,
    createdAt: '2026-01-01T00:00:00.000Z',
  );
}

WorkspaceMemberEntity buildWorkspaceMemberEntity({String userId = 'user-1'}) {
  return WorkspaceMemberEntity(
    userId: userId,
    name: 'Recruiter',
    email: 'recruiter@example.com',
    photo: 'https://example.com/photo.png',
    designation: 'HR',
    joinedAt: '2026-01-01T00:00:00.000Z',
  );
}

RecruiterWorkspaceEntity buildRecruiterWorkspaceEntity() {
  return const RecruiterWorkspaceEntity(
    companyId: 'company-1',
    companyName: 'Kaarya',
    companyLogo: 'https://example.com/logo.png',
    designation: 'HR',
    joinedAt: '2026-01-01T00:00:00.000Z',
  );
}

CollegeEntity buildCollegeEntity({String id = 'college-1'}) {
  return CollegeEntity(
    id: id,
    name: 'TU',
    institutionType: 'University',
    location: 'Kathmandu',
    logo: 'https://example.com/logo.png',
    inviteCode: 'COLLEGE123',
    studentsCount: 100,
    createdAt: '2026-01-01T00:00:00.000Z',
  );
}

StudentMemberEntity buildStudentMemberEntity({String userId = 'student-1'}) {
  return StudentMemberEntity(
    userId: userId,
    name: 'Student',
    email: 'student@example.com',
    photo: 'https://example.com/photo.png',
    program: 'BSc CSIT',
    year: 4,
    joinedAt: '2026-01-01T00:00:00.000Z',
  );
}

CollegeWorkspaceEntity buildCollegeWorkspaceEntity() {
  return const CollegeWorkspaceEntity(
    collegeId: 'college-1',
    collegeName: 'TU',
    collegeLogo: 'https://example.com/logo.png',
    joinedAt: '2026-01-01T00:00:00.000Z',
  );
}

CollegeMetricsEntity buildCollegeMetricsEntity() {
  return CollegeMetricsEntity(
    totalStudents: 100,
    totalJobs: 10,
    totalInterviews: 20,
    totalApplications: 50,
    averageInterviewScore: 81,
    averageAtsScore: 76,
    topStudents: [buildStudentMemberEntity()],
  );
}

LeaderboardEntity buildLeaderboardEntity() {
  return const LeaderboardEntity(
    entries: [
      LeaderboardEntryEntity(
        rank: '1',
        userId: 'user-1',
        name: 'Top User',
        photo: 'https://example.com/photo.png',
        xp: 1200,
        score: 98,
        kRank: 1,
        level: 'Elite',
        college: 'TU',
        isCurrentUser: true,
      ),
    ],
    totalEntries: 1,
    currentUserEntry: LeaderboardEntryEntity(
      rank: '1',
      userId: 'user-1',
      name: 'Top User',
      photo: 'https://example.com/photo.png',
      xp: 1200,
      score: 98,
      kRank: 1,
      level: 'Elite',
      college: 'TU',
      isCurrentUser: true,
    ),
  );
}

DashboardOverviewEntity buildDashboardOverviewEntity() {
  return DashboardOverviewEntity(
    summary: const DashboardApplicationsSummaryEntity(
      total: 124,
      delta: 10,
      todayCount: 3,
      monthKey: '2026-03',
      monthLabel: 'March 2026',
      recentCompanies: [
        DashboardRecentCompanyEntity(
          workspaceId: 'company-1',
          workspaceType: 'company',
          name: 'Kaarya',
          logo: 'https://example.com/logo.png',
          applicationsCount: 5,
        ),
      ],
      appliedCount: 50,
      reviewingCount: 30,
      shortlistedCount: 20,
      interviewCount: 18,
      acceptedCount: 4,
      rejectedCount: 1,
      withdrawnCount: 1,
    ),
    deadlineJob: buildJobEntity(),
    invitation: const DashboardInvitationEntity(
      title: 'Interview Invitation',
      description: 'You have a new invitation',
      eventTitle: 'Technical Round',
      eventTime: '10:00 AM',
      companyName: 'Kaarya',
      companyLogo: 'https://example.com/logo.png',
      interviewScheduledAt: '2026-03-10T10:00:00.000Z',
    ),
    jobs: buildJobsBucketEntity(),
    readinessPoints: const [
      DashboardInterviewReadinessPointEntity(
        label: 'Mock Interviews',
        score: 18,
      ),
    ],
    analytics: const DashboardAnalyticsEntity(
      applicationsThisWeek: 12,
      interviewConversion: 35.5,
      momentum: [
        DashboardMomentumPointEntity(
          label: 'Week 1',
          applications: 4,
          interviews: 1,
        ),
      ],
      pipeline: [
        DashboardPipelinePointEntity(
          stage: 'Applied',
          thisWeek: 5,
          lastWeek: 3,
        ),
      ],
      invitationMix: [
        DashboardInvitationMixPointEntity(
          name: 'Tech',
          value: 60,
          fill: '#000',
        ),
      ],
    ),
    profileRating: 82,
    interviewOverallRating: 74,
  );
}
