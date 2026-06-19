import '../../network/api_client.dart';
import '../../network/api_service.dart';
import '../../utils/custom_exception.dart';
import '../../utils/result.dart';
import '../models/app_settings.dart';

class AppSettingsService {
  final ApiService _api;

  AppSettingsService({ApiService? api}) : _api = api ?? ApiService();

  Future<Result<AppSettings, CustomException>> getSettings() {
    return _api.getJson<AppSettings>(
      endpoint: ApiClient.appSettings,
      fromJson: (json) => AppSettings.fromJson(json),
    );
  }
}
