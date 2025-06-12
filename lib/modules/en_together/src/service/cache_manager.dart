import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class NoExpiryCacheManager extends CacheManager {
  static const key = "noExpiryCache";

  static final NoExpiryCacheManager _instance = NoExpiryCacheManager._internal();

  factory NoExpiryCacheManager() => _instance;

  NoExpiryCacheManager._internal()
      : super(Config(
    key,
    stalePeriod: const Duration(days: 365 * 100),
    maxNrOfCacheObjects: 200,
  ));
}
