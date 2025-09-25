import 'package:get_it/get_it.dart';

// Firebase Auth imports
import '../../features/auth/data/datasources/firebase_auth_datasource.dart';
import '../../features/auth/data/repositories/firebase_auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

// Firebase Duty imports
import '../../features/duty/data/datasources/firestore_duty_datasource.dart';
import '../../features/duty/data/repositories/firestore_duty_repository_impl.dart';
import '../../features/duty/domain/repositories/duty_repository.dart';

// Firebase Reports imports
import '../../features/reports/data/datasources/firestore_reports_datasource.dart';
import '../../features/reports/data/repositories/firestore_reports_repository_impl.dart';
import '../../features/reports/domain/repositories/reports_repository.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Configure Firebase data sources
  await _configureFirebaseDataSources();

  // Configure repositories with Firebase data sources
  await _configureRepositories();
}

Future<void> _configureFirebaseDataSources() async {
  // Firebase Auth Data Source
  getIt.registerLazySingleton<FirebaseAuthDataSource>(
    () => FirebaseAuthDataSourceImpl(),
  );

  // Firestore Duty Data Source
  getIt.registerLazySingleton<FirestoreDutyDataSource>(
    () => FirestoreDutyDataSourceImpl(),
  );

  // Firestore Reports Data Source
  getIt.registerLazySingleton<FirestoreReportsDataSource>(
    () => FirestoreReportsDataSourceImpl(
      dutyDataSource: getIt<FirestoreDutyDataSource>(),
    ),
  );
}

Future<void> _configureRepositories() async {
  // Auth Repository with Firebase
  getIt.registerLazySingleton<AuthRepository>(
    () =>
        FirebaseAuthRepositoryImpl(dataSource: getIt<FirebaseAuthDataSource>()),
  );

  // Duty Repository with Firestore
  getIt.registerLazySingleton<DutyRepository>(
    () => FirestoreDutyRepositoryImpl(
      dataSource: getIt<FirestoreDutyDataSource>(),
    ),
  );

  // Reports Repository with Firestore
  getIt.registerLazySingleton<ReportsRepository>(
    () => FirestoreReportsRepositoryImpl(
      dataSource: getIt<FirestoreReportsDataSource>(),
    ),
  );
}
