import 'package:dartz/dartz.dart';
import 'dart:async';
import '../../../core/export.dart';
import '../../../core/models/res_model/connects_history.dart';
import '../../../core/services/network_services/result_type.dart';

mixin SystemConfigRepo {
  Future<Either<AppError, AllCast>> getAllCasts();

  Future<Either<AppError, AllDegrees>> getAllDegrees();

  Future<Either<AppError, AllOccupations>> getAllOccupations();

  Future<Either<AppError, List<AllCountries>>> getAllCountries();

  Future<Either<AppError, List<AllStates>>> getAllStates({
    required int countryId,
  });

  Future<Either<AppError, List<AllCities>>> getAllCities({
    required int stateId,
  });

  Future<Either<AppError, String>> getConnects();

  Future<Either<AppError, String>> getUserNumber(email);

  Future<Either<AppError, String>> buyConnects({
    required int connect,
    required String connectDesc,
  });

  Future<Either<AppError, String>> deductConnects({
    required int userForId,
  });

  Future<Either<AppError, String>> createTransaction({
    required String googleConsoleId,
    required String transactionId,

  });
  Future<Either<AppError, String>> createGoogleTransaction({
    required String googleConsoleId,
    required String transactionId,
    required String currencyCode,
    required double amount,
    required double discountedAmount,
    required int actualAmount,
    required String paymentSource,

  });

  Future<Either<AppError, List<TransactionHistory>>> transactionHistory();
  Future<Either<AppError, List<ConnectsHistory>>> connectsHistory();

  Future<Either<AppError, String>> contactUs({
    required String name,
    required String email,
    required String subject,
    required String message,
  });

  Future<Either<AppError, String>> getPaymentToken({
    required String basketId,
    required String amount,
  });
}
