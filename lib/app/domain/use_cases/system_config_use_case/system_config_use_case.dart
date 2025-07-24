import 'package:dartz/dartz.dart';


import '../../../core/export.dart';
import '../../../core/services/network_services/result_type.dart';
import '../../export.dart';


class SystemConfigUseCase {
  SystemConfigRepo systemConfigRepo;

  SystemConfigUseCase(this.systemConfigRepo);

  Future<Either<AppError, AllCast>> getAllCasts() async {
    final response = await systemConfigRepo.getAllCasts();
    return response.fold(
      (error) {
        return Left(error);
      },
      (success) {
        return Right(success);
      },
    );
  }

  Future<Either<AppError, AllDegrees>> getAllDegrees() async {
    final response = await systemConfigRepo.getAllDegrees();
    return response.fold(
      (error) {
        return Left(error);
      },
      (success) {
        return Right(success);
      },
    );
  }

  Future<Either<AppError, AllOccupations>> getAllOccupations() async {
    final response = await systemConfigRepo.getAllOccupations();
    return response.fold(
      (error) {
        return Left(error);
      },
      (success) {
        return Right(success);
      },
    );
  }

  Future<Either<AppError, List<AllCountries>>> getAllCountries() async {
    final response = await systemConfigRepo.getAllCountries();
    return response.fold(
      (error) {
        return Left(error);
      },
      (success) {
        return Right(success);
      },
    );
  }

  Future<Either<AppError, List<AllStates>>> getAllStates({
    required int countryId,
  }) async {
    final response = await systemConfigRepo.getAllStates(countryId: countryId);
    return response.fold(
      (error) {
        return Left(error);
      },
      (success) {
        return Right(success);
      },
    );
  }

  Future<Either<AppError, List<AllCities>>> getAllCities({
    required int stateId,
  }) async {
    final response = await systemConfigRepo.getAllCities(stateId: stateId);
    return response.fold(
      (error) {
        return Left(error);
      },
      (success) {
        return Right(success);
      },
    );
  }

  Future<Either<AppError, String>> getConnects() async {
    final response = await systemConfigRepo.getConnects();
    return response.fold(
      (error) {
        return Left(error);
      },
      (success) {
        return Right(success);
      },
    );
  }

  Future<Either<AppError, String>> buyConnects({
    required int connect,
    required String connectDesc,
  }) async {
    final response = await systemConfigRepo.buyConnects(
      connect: connect,
      connectDesc: connectDesc,
    );

    return response.fold(
      (error) {
        return Left(error);
      },
      (success) {
        return Right(success);
      },
    );
  }

  Future<Either<AppError, String>> deductConnects({
    required int userForId,
  }) async {
    final response = await systemConfigRepo.deductConnects(
      userForId: userForId,
    );
    return response.fold(
      (error) {
        return Left(error);
      },
      (success) {
        return Right(success);
      },
    );
  }

  Future<Either<AppError, String>> createTransaction({
    required String connectsPackagesId,
    required String transactionId,
  }) async {
    final response = await systemConfigRepo.createTransaction(
      connectsPackagesId: connectsPackagesId,
      transactionId: transactionId,
    );
    return response.fold(
      (error) {
        return Left(error);
      },
      (success) {
        return Right(success);
      },
    );
  }


  Future<Either<AppError, List<TransactionHistory>>> transactionHistory() async {
    final response = await systemConfigRepo.transactionHistory();
    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        return Right(success);
      },
    );
  }

  Future<Either<AppError, String>> contactUs({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    final response = await systemConfigRepo.contactUs(
      name: name,
      email: email,
      subject: subject,
      message: message,
    );

    return response.fold(
      (error) {
        return Left(error);
      },
      (success) {
        return Right(success);
      },
    );
  }

  Future<Either<AppError, String>> getPaymentToken({
    required String basketId,
    required String amount,
  }) async {
    final response = await systemConfigRepo.getPaymentToken(
      basketId: basketId,
      amount: amount,
    );

    return response.fold(
      (error) {
        return Left(error);
      },
      (success) {
        return Right(success);
      },
    );
  }
}
