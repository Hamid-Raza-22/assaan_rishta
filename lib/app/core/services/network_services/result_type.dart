class AppError {
  final String title;
  final String description;
  final int statusCode;

  AppError({this.title = "", this.description = "", this.statusCode = 200});

  @override
  int get hashCode => title.hashCode ^ description.hashCode;

  factory AppError.copy(
      {String title = "", String description = "", int statusCode = 200}) {
    return AppError(
      title: title,
      description: description,
      statusCode: statusCode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppError &&
          other.title == title &&
          other.description == description &&
          other.statusCode == statusCode);
}

class AppSuccess {
  @override
  bool operator == (Object other) =>
      identical(this, other) || other is AppSuccess;

}

AppError getLoggedError(String analyticsKey,
    {String title = "", String description = "", int statusCode = 200}) {
  AppError appError = AppError(
    title: title,
    description: description,
    statusCode: statusCode,
  );
  return appError;
}
