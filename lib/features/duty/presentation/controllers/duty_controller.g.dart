// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'duty_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DutyController)
const dutyControllerProvider = DutyControllerProvider._();

final class DutyControllerProvider
    extends $NotifierProvider<DutyController, DutyState> {
  const DutyControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dutyControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dutyControllerHash();

  @$internal
  @override
  DutyController create() => DutyController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DutyState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DutyState>(value),
    );
  }
}

String _$dutyControllerHash() => r'81f6a0abeca3bd4d05d486949f3c156c873e502c';

abstract class _$DutyController extends $Notifier<DutyState> {
  DutyState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<DutyState, DutyState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DutyState, DutyState>,
              DutyState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
