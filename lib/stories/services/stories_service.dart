import '../../network/api_client.dart';
import '../../network/api_service.dart';
import '../../utils/custom_exception.dart';
import '../../utils/result.dart';
import '../models/employee_story_dto.dart';

class StoriesService {
  final ApiService _api;

  StoriesService({ApiService? api}) : _api = api ?? ApiService();

  Future<Result<EmployeeStoriesResponse, CustomException>> getEmployeeStories(
    int employeeId,
  ) {
    return _api.getJson<EmployeeStoriesResponse>(
      endpoint: ApiClient.employeeStories(employeeId),
      fromJson: (json) => EmployeeStoriesResponse.fromJson(json),
    );
  }

  Future<Result<EmployeeStoriesResponse, CustomException>> getEmployerStories(
    int employerId,
  ) {
    return _api.getJson<EmployeeStoriesResponse>(
      endpoint: ApiClient.employerStories(employerId),
      fromJson: (json) => EmployeeStoriesResponse.fromJson(json),
    );
  }

  Future<Result<StoryMarkReadResponse, CustomException>> markEmployeeStoryRead({
    required int employeeId,
    required int storyId,
  }) {
    return _api.postJson<StoryMarkReadResponse>(
      endpoint: ApiClient.employeeStoryMarkRead,
      body: {'employee_id': employeeId, 'story_id': storyId},
      fromJson: (json) => StoryMarkReadResponse.fromJson(json),
    );
  }

  Future<Result<StoryMarkReadResponse, CustomException>> markEmployerStoryRead({
    required int employerId,
    required int storyId,
  }) {
    return _api.postJson<StoryMarkReadResponse>(
      endpoint: ApiClient.employerStoryMarkRead,
      body: {'employer_id': employerId, 'story_id': storyId},
      fromJson: (json) => StoryMarkReadResponse.fromJson(json),
    );
  }
}
