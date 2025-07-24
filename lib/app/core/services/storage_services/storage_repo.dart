mixin StorageRepo {
  String? getString(String key);

  void setString(String key, String value);

  int? getInt(String key);

  void setInt(String key, int value);

  bool? getBool(String key);

  bool contains(String key);

  Future<bool> remove(String key);

  void setBool(String key, bool value);

  void setDouble(String key,double value);

  double? getDouble(String key);

  Set<String>? getKeys();

  Future<void> clear();
}
