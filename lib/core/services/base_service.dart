import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BaseService {
  Future<T> handleAsync<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on FirebaseException catch (e) {
      throw ServiceException(e.message ?? 'Firebase error occurred');
    } catch (e) {
      throw ServiceException('An unexpected error occurred');
    }
  }
}

class ServiceException implements Exception {
  final String message;
  ServiceException(this.message);

  @override
  String toString() => message;
}
