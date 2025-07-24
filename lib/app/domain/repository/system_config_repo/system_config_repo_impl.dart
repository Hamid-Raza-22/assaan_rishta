import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../../../core/export.dart';
import '../../../core/services/network_services/end_points.dart';
import '../../../core/services/network_services/network_helper.dart';
import '../../../core/services/network_services/result_type.dart';
import '../../../core/services/storage_services/storage_keys.dart';
import '../../../core/services/storage_services/storage_repo.dart';
import 'export.dart';

class SystemConfigRepoImpl implements SystemConfigRepo {
  final StorageRepo _storageRepo;
  final NetworkHelper _networkHelper;
  final EndPoints _endPoints;
  final SharedPreferences sharedPreferences;

  SystemConfigRepoImpl(
    this._storageRepo,
    this._networkHelper,
    this._endPoints,
    this.sharedPreferences,
  );

  @override
  Future<Either<AppError, AllCast>> getAllCasts() async {
    try {
      final response = await _networkHelper.get(_endPoints.getAllCastsUrl());
      AllCast model = AllCast();
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        List<dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse.isNotEmpty) {
          model = AllCast.fromJson(jsonResponse);
          return Right(model);
        }
        return Left(
          AppError(
            title: response.statusCode.toString(),
            description: "Something went wrong!",
          ),
        );
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          description: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, AllOccupations>> getAllOccupations() async {
    try {
      final response =
          await _networkHelper.get(_endPoints.getAllOccupationsUrl());
      AllOccupations model = AllOccupations();
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        List<dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse.isNotEmpty) {
          model = AllOccupations.fromJson(jsonResponse);
          return Right(model);
        }
        return Left(
          AppError(
            title: response.statusCode.toString(),
            description: "Something went wrong!",
          ),
        );
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          description: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, AllDegrees>> getAllDegrees() async {
    try {
      final response = await _networkHelper.get(_endPoints.getAllDegreesUrl());
      AllDegrees model = AllDegrees();
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        List<dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse.isNotEmpty) {
          model = AllDegrees.fromJson(jsonResponse);
          return Right(model);
        }
        return Left(
          AppError(
            title: response.statusCode.toString(),
            description: "Something went wrong!",
          ),
        );
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          description: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, List<AllCountries>>> getAllCountries() async {
    try {
      final response =
          await _networkHelper.get(_endPoints.getAllCountriesUrl());
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        List<dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse.isNotEmpty) {
          return Right(AllCountries.fromJsonList(jsonResponse));
        }
        return Left(
          AppError(
            title: response.statusCode.toString(),
          ),
        );
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          title: "Network Exception",
          description: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, List<AllStates>>> getAllStates(
      {required int countryId}) async {
    try {
      final response = await _networkHelper
          .get(_endPoints.getStatesByCountryIdUrl(countryId: countryId));
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        List<dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse.isNotEmpty) {
          return Right(AllStates.fromJsonList(jsonResponse));
        }
        return Left(
          AppError(
            title: response.statusCode.toString(),
          ),
        );
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          title: "Network Exception",
          description: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, List<AllCities>>> getAllCities({
    required int stateId,
  }) async {
    try {
      final response = await _networkHelper
          .get(_endPoints.getCityByStateIdUrl(stateId: stateId));
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        List<dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse.isNotEmpty) {
          return Right(AllCities.fromJsonList(jsonResponse));
        }
        return Left(
          AppError(
            title: response.statusCode.toString(),
          ),
        );
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          title: "Network Exception",
          description: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, String>> getConnects() async {
    try {
      final response = await _networkHelper.get(
        _endPoints.getConnectsUrl(
          uid: _storageRepo.getInt(StorageKeys.userId),
        ),
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return Right(response.body.toString());
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          title: "Network Exception",
          description: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, String>> buyConnects({
    required int connect,
    required String connectDesc,
  }) async {
    try {
      final response = await _networkHelper.post(
        _endPoints.buyConnectsUrl(),
        body: {
          "connects": connect,
          "connectionDescription": connectDesc,
          "userId": _storageRepo.getInt(StorageKeys.userId).toString(),
        },
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return Right(response.body.toString());
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          title: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, String>> deductConnects({
    required int userForId,
  }) async {
    try {
      final response = await _networkHelper.get(
        _endPoints.deductConnectsUrl(
          uid: _storageRepo.getInt(StorageKeys.userId).toString(),
          userForId: userForId,
        ),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return Right(response.body.toString());
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          title: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, String>> createTransaction({
    required String connectsPackagesId,
    required String transactionId,
  }) async {
    try {
      final response = await _networkHelper.post(
        _endPoints.createTransactionUrl(),
        headers: {"Content-Type": "application/json"},
        body: {
          "user_id": _storageRepo.getInt(StorageKeys.userId).toString(),
          "connectsPackagesId": connectsPackagesId,
          "transaction_Id": transactionId,
        },
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return Right(response.body.toString());
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          title: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, List<TransactionHistory>>>
      transactionHistory() async {
    try {
      final response = await _networkHelper.get(
        _endPoints.transactionHistoryUrl(
          _storageRepo.getInt(StorageKeys.userId).toString(),
        ),
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        List<dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse.isNotEmpty) {
          return Right(TransactionHistory.fromJsonList(jsonResponse));
        }
        return Left(
          AppError(
            title: response.statusCode.toString(),
          ),
        );
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          title: "Network Exception",
          description: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, String>> contactUs({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    try {
      final response = await _networkHelper.post(
        _endPoints.contactUsUrl(),
        body: {
          "name": name,
          "email": email,
          "subject": subject,
          "message": message,
        },
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return Right(response.body.toString());
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          title: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, String>> getPaymentToken({
    required String basketId,
    required String amount,
  }) async {
    try {
      final response = await _networkHelper.get(
        _endPoints.getPaymentTokenUrl(
          basketId: basketId,
          amount: amount,
        ),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final data = jsonDecode(response.body);
        if (data != null && data['token'] != null) {
          return Right(data['token']);
        } else {
          return Left(AppError(title: "Token not found in response"));
        }
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          title: e.toString(),
        ),
      );
    }
  }
}
