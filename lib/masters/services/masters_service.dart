import "../../network/api_client.dart";
import "../../network/api_service.dart";
import "../../utils/custom_exception.dart";
import "../../utils/result.dart";
import "../models/location_dtos.dart";
import "../models/masters_bundle.dart";

class MastersService {
  final ApiService _api;

  MastersService({ApiService? api}) : _api = api ?? ApiService();

  Future<Result<MastersBundle, CustomException>> getAllMasters() {
    return _api.getJson<MastersBundle>(
      endpoint: ApiClient.mastersGetAll,
      fromJson: (json) => MastersBundle.fromJson(json),
    );
  }

  Future<Result<List<CityDto>, CustomException>> getCitiesByState(int stateId) {
    return _api.getJson<List<CityDto>>(
      endpoint: ApiClient.mastersCitiesByState(stateId),
      fromJson: (json) {
        final cities = json?["cities"];
        if (cities is! List) return const <CityDto>[];
        return cities
            .map((e) => e is Map<String, dynamic> ? CityDto.fromJson(e) : null)
            .whereType<CityDto>()
            .toList();
      },
    );
  }
}
