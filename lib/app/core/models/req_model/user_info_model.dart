class UserInfoModel {
  final String name;
  final String job;
  final String city;
  final double rating;

  UserInfoModel({
    required this.name,
    required this.job,
    required this.city,
    required this.rating,
  });
}

final List<UserInfoModel> candidates = [
  UserInfoModel(
    name: 'Ijaz',
    job: 'Developer',
    city: 'Lahore, Pakistan',
    rating: 5.0,
  ),
  UserInfoModel(
    name: 'Hassan',
    job: 'Manager',
    city: 'New York',
    rating: 4.0,
  ),
  UserInfoModel(
    name: 'Azam',
    job: 'Engineer',
    city: 'London',
    rating: 3.0,
  ),
  UserInfoModel(
    name: 'Ali',
    job: 'Designer',
    city: 'Tokyo',
    rating: 3.5,
  ),
];
