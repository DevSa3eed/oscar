// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [DutyAssignmentPage]
class DutyAssignmentRoute extends PageRouteInfo<void> {
  const DutyAssignmentRoute({List<PageRouteInfo>? children})
    : super(DutyAssignmentRoute.name, initialChildren: children);

  static const String name = 'DutyAssignmentRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DutyAssignmentPage();
    },
  );
}

/// generated route for
/// [DutyCheckPage]
class DutyCheckRoute extends PageRouteInfo<DutyCheckRouteArgs> {
  DutyCheckRoute({
    Key? key,
    required DutyPerson dutyPerson,
    DutyCheck? existingDutyCheck,
    List<PageRouteInfo>? children,
  }) : super(
         DutyCheckRoute.name,
         args: DutyCheckRouteArgs(
           key: key,
           dutyPerson: dutyPerson,
           existingDutyCheck: existingDutyCheck,
         ),
         initialChildren: children,
       );

  static const String name = 'DutyCheckRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DutyCheckRouteArgs>();
      return DutyCheckPage(
        key: args.key,
        dutyPerson: args.dutyPerson,
        existingDutyCheck: args.existingDutyCheck,
      );
    },
  );
}

class DutyCheckRouteArgs {
  const DutyCheckRouteArgs({
    this.key,
    required this.dutyPerson,
    this.existingDutyCheck,
  });

  final Key? key;

  final DutyPerson dutyPerson;

  final DutyCheck? existingDutyCheck;

  @override
  String toString() {
    return 'DutyCheckRouteArgs{key: $key, dutyPerson: $dutyPerson, existingDutyCheck: $existingDutyCheck}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DutyCheckRouteArgs) return false;
    return key == other.key &&
        dutyPerson == other.dutyPerson &&
        existingDutyCheck == other.existingDutyCheck;
  }

  @override
  int get hashCode =>
      key.hashCode ^ dutyPerson.hashCode ^ existingDutyCheck.hashCode;
}

/// generated route for
/// [HodDashboardPage]
class HodDashboardRoute extends PageRouteInfo<void> {
  const HodDashboardRoute({List<PageRouteInfo>? children})
    : super(HodDashboardRoute.name, initialChildren: children);

  static const String name = 'HodDashboardRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HodDashboardPage();
    },
  );
}

/// generated route for
/// [LocationManagementPage]
class LocationManagementRoute extends PageRouteInfo<void> {
  const LocationManagementRoute({List<PageRouteInfo>? children})
    : super(LocationManagementRoute.name, initialChildren: children);

  static const String name = 'LocationManagementRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LocationManagementPage();
    },
  );
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginPage();
    },
  );
}

/// generated route for
/// [ProfilePage]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfilePage();
    },
  );
}

/// generated route for
/// [RegisterPage]
class RegisterRoute extends PageRouteInfo<void> {
  const RegisterRoute({List<PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RegisterPage();
    },
  );
}

/// generated route for
/// [ReminderEmailPage]
class ReminderEmailRoute extends PageRouteInfo<ReminderEmailRouteArgs> {
  ReminderEmailRoute({
    Key? key,
    DutyIssue? issue,
    List<PageRouteInfo>? children,
  }) : super(
         ReminderEmailRoute.name,
         args: ReminderEmailRouteArgs(key: key, issue: issue),
         initialChildren: children,
       );

  static const String name = 'ReminderEmailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ReminderEmailRouteArgs>(
        orElse: () => const ReminderEmailRouteArgs(),
      );
      return ReminderEmailPage(key: args.key, issue: args.issue);
    },
  );
}

class ReminderEmailRouteArgs {
  const ReminderEmailRouteArgs({this.key, this.issue});

  final Key? key;

  final DutyIssue? issue;

  @override
  String toString() {
    return 'ReminderEmailRouteArgs{key: $key, issue: $issue}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ReminderEmailRouteArgs) return false;
    return key == other.key && issue == other.issue;
  }

  @override
  int get hashCode => key.hashCode ^ issue.hashCode;
}

/// generated route for
/// [ReportsPage]
class ReportsRoute extends PageRouteInfo<void> {
  const ReportsRoute({List<PageRouteInfo>? children})
    : super(ReportsRoute.name, initialChildren: children);

  static const String name = 'ReportsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ReportsPage();
    },
  );
}

/// generated route for
/// [SplashPage]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashPage();
    },
  );
}

/// generated route for
/// [SupervisorHomePage]
class SupervisorHomeRoute extends PageRouteInfo<void> {
  const SupervisorHomeRoute({List<PageRouteInfo>? children})
    : super(SupervisorHomeRoute.name, initialChildren: children);

  static const String name = 'SupervisorHomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SupervisorHomePage();
    },
  );
}
