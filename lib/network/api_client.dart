class ApiClient {
  // Single base URL for your backend.
  // Example (local iOS simulator): 'http://localhost:5001'
  // Example (Android emulator): 'http://10.0.2.2:5001'
  // static const String baseUrl = 'http://192.168.1.5:5001';
  static const String baseUrl = 'https://labormint.com';

  // Mobile backend base path (see backend/server.js: app.use('/api/app', require('./apis')))
  static const String basePath = '/api/app';

  // -------- Masters --------
  static const String mastersGetAll = '/masters';
  static String mastersCitiesByState(int stateId) =>
      '/masters/states/$stateId/cities';

  // -------- Auth --------
  static const String authSendLoginOtp = '/auth/login/send-otp';
  static const String authVerifyLoginOtp = '/auth/login/verify-otp';
  static const String authSendSignupOtp = '/auth/signup/send-otp';
  static const String authVerifySignupOtp = '/auth/signup/verify-otp';

  // -------- Users --------
  static const String appSettings = '/settings';

  // -------- Deep-link helpers --------
  static String jobIdBySlug(String slug) => '/jobs/slug/$slug';
  static String candidateIdBySlug(String slug) => '/candidates/slug/$slug';

  static String userById(int userId) => "/users/$userId";

  static String userNotifications(int userId) => '/users/$userId/notifications';

  static String userNotificationsRead(int userId) =>
      '/users/$userId/notifications/read';

  static String userPreferredLanguage(int userId) =>
      '/users/$userId/preferred-language';

  static String userLastActive(int userId) => '/users/$userId/last-active';

  static String userDeleteRequest(int userId) =>
      '/users/$userId/delete-request';

  static String userUpdateFcmToken(int userId) => '/users/$userId/fcm-token';

  static String userCreateReview(int userId) => '/users/$userId/reviews';

  // -------- Employers --------
  static String employerById(int id) => '/employers/$id';
  static String employerProfile(int employerId) =>
      '/employers/$employerId/profile';
  static String employerPersonalInfo(int userId) =>
      '/employers/$userId/personal-info';

  static String employerAadharSendOtp(int employerId) =>
      '/employers/$employerId/aadhar/send-otp';

  static String employerAadharVerifyOtp(int employerId) =>
      '/employers/$employerId/aadhar/verify-otp';

  static String employerDocument(int employerId) =>
      '/employers/$employerId/document';

  static String employerJobs(int employerId) => '/employers/$employerId/jobs';

  static String employerApplicants(int employerId) =>
      '/employers/$employerId/applicants';

  static String employerApplicantsReceived(int employerId) =>
      '/employers/$employerId/applicants/received';

  static String employerApplicantsSent(int employerId) =>
      '/employers/$employerId/applicants/sent';

  static String employerApplicantsShortlisted(int employerId) =>
      '/employers/$employerId/applicants/shortlisted';

  static String employerApplicantsHired(int employerId) =>
      '/employers/$employerId/applicants/hired';

  static String employerApplicantsRejected(int employerId) =>
      '/employers/$employerId/applicants/rejected';

  static String employerShortlistedCandidates(int employerId) =>
      '/employers/$employerId/shortlisted-candidates';

  static String employerApplicantsStatus(int employerId) =>
      '/employers/$employerId/applicants/status';

  static String employerSubscriptions(int employerId) =>
      '/employers/$employerId/subscriptions';
  static String employerBuySubscription(int employerId) =>
      '/employers/$employerId/subscriptions/buy';
  static String employerSubscriptionPaymentStatus(
    int employerId,
    String orderId,
  ) => '/employers/$employerId/subscriptions/status/$orderId';

  static String employerContactsHistory(int employerId) =>
      '/employers/$employerId/history/contacts';
  static String employerInterestsHistory(int employerId) =>
      '/employers/$employerId/history/interests';
  static String employerAdsHistory(int employerId) =>
      '/employers/$employerId/history/ads';
  static String employerPaymentsHistory(int employerId) =>
      '/employers/payments/history/$employerId';

  // Employer -> candidate actions
  static String employerCandidateJobsSendInterest(
    int employerId,
    int candidateId,
  ) => '/employers/candidates/jobs/send-interest/$employerId/$candidateId';

  static String employerCandidateJobsShortlist(
    int employerId,
    int candidateId,
  ) => '/employers/candidates/jobs/shortlist/$employerId/$candidateId';

  static const String employerCandidateSendInterestPost =
      '/employers/candidates/jobs/send-interest';

  static const String employerCandidateShortlistPost =
      '/employers/candidates/jobs/shortlist';

  static const String employerCandidateShortlistTogglePost =
      '/employers/candidates/shortlist/toggle';

  static const String employerCandidateCallExperience =
      '/employers/candidates/call-experience';

  // -------- Employees --------
  static String employeeById(int id) => '/employees/$id';

  static String employeePersonalInfo(int userId) =>
      '/employees/$userId/personal-info';

  static String employeeJobProfiles(int employeeId) =>
      '/employees/$employeeId/job-profiles';

  static String employeeExperiences(int employeeId) =>
      '/employees/$employeeId/experiences';
  static String employeeExperienceById(int experienceId) =>
      '/employees/experiences/$experienceId';

  static String employeeDocuments(int employeeId) =>
      '/employees/$employeeId/documents';
  static String employeeSubmitForReview(int employeeId) =>
      '/employees/$employeeId/submit-for-review';
  static String employeeDocumentById(int documentId) =>
      '/employees/documents/$documentId';

  static String employeeAadharSendOtp(int employeeId) =>
      '/employees/$employeeId/aadhar/send-otp';
  static String employeeAadharVerifyOtp(int employeeId) =>
      '/employees/$employeeId/aadhar/verify-otp';

  static String employeeSelfie(int employeeId) =>
      '/employees/$employeeId/selfie';

  static String employeeContactsHistory(int employeeId) =>
      '/employees/$employeeId/contacts/history';
  static String employeeInterestsHistory(int employeeId) =>
      '/employees/$employeeId/interests/history';
  static String employeeHiredJobs(int employeeId) =>
      '/employees/$employeeId/hired';
  static String employeePaymentsHistory(int employeeId) =>
      '/employees/$employeeId/payments/history';
  static String employeeSubscriptions(int employeeId) =>
      '/employees/$employeeId/subscriptions';
  static String employeeBuySubscription(int employeeId) =>
      '/employees/$employeeId/subscriptions/buy';
  static String employeeSubscriptionPaymentStatus(
    int employeeId,
    String orderId,
  ) => '/employees/$employeeId/subscriptions/status/$orderId';
  static String employeeWishlist(int employeeId) =>
      '/employees/$employeeId/wishlist';

  // -------- Payments --------
  static String paymentInvoicePdf(int paymentHistoryId) =>
      '/payments/invoice/$paymentHistoryId';

  static const String employeeUnlockJobContact =
      '/employees/jobs/unlock-contact';
  static const String employeeSaveCallExperience =
      '/employees/jobs/call-experience';
  static const String employeeSendJobInterest = '/employees/jobs/interest';

  static const String employeeUnlockApplicationOtp =
      '/employees/jobs/unlock-application-otp';
  static const String employeeReportJob = '/employees/jobs/report';
  static const String employeeToggleWishlist =
      '/employees/jobs/wishlist/toggle';

  static String employeeApplicationsSent(int employeeId) =>
      '/employees/$employeeId/applications/sent';
  static String employeeApplicationsReceived(int employeeId) =>
      '/employees/$employeeId/applications/received';

  // -------- Jobs --------
  static const String jobsGetAll = '/jobs';
  static String jobsRecommended(int employeeId) =>
      '/jobs/recommended/$employeeId';

  static String jobsEmployerSave(int employerId) =>
      '/jobs/employer/$employerId/save';

  static String jobsEmployerDetail(int employerId, int jobId) =>
      '/jobs/employer/$employerId/$jobId/detail';

  static String jobsEmployerApplicantsReceived(int employerId, int jobId) =>
      '/jobs/employer/$employerId/$jobId/applicants/received';

  static String jobsEmployerApplicantsSent(int employerId, int jobId) =>
      '/jobs/employer/$employerId/$jobId/applicants/sent';

  static String jobsEmployerApplicantsShortlisted(int employerId, int jobId) =>
      '/jobs/employer/$employerId/$jobId/applicants/shortlisted';

  static String jobsEmployerApplicantsHired(int employerId, int jobId) =>
      '/jobs/employer/$employerId/$jobId/applicants/hired';

  static String jobsEmployerApplicantsRejected(int employerId, int jobId) =>
      '/jobs/employer/$employerId/$jobId/applicants/rejected';

  static String jobsDetail(int jobId, int employeeId) =>
      '/jobs/detail/$jobId/$employeeId';

  static const String jobsWishlistToggle = '/jobs/wishlist/toggle';

  static String jobsInterviewerSendOtp(int employerId) =>
      '/jobs/interviewer-contact/send-otp/$employerId';

  static String jobsInterviewerVerifyOtp(int employerId) =>
      '/jobs/interviewer-contact/verify-otp/$employerId';

  // Stories
  static String employeeStories(int employeeId) =>
      '/stories/employee/$employeeId';
  static const String employeeStoryMarkRead = '/stories/employee/mark-read';

  static String employerStories(int employerId) =>
      '/stories/employer/$employerId';
  static const String employerStoryMarkRead = '/stories/employer/mark-read';

  // -------- Candidates --------
  static const String candidatesGetAll = '/candidates';
  static String candidatesRecommended(int employerId) =>
      '/candidates/recommended/$employerId';

  static String candidatesDetail(int candidateId, int employerId) =>
      '/candidates/detail/$candidateId/$employerId';

  static const String candidatesUnlockContact = '/candidates/unlock-contact';
  static const String candidatesReport = '/candidates/report';
}
