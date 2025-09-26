import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/app_router.dart';
import '../../domain/entities/user.dart';

@RoutePage()
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  // Staggered animations
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _backgroundFadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupStaggeredAnimations();
    _initializeApp();
  }

  void _setupStaggeredAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500), // Shortened to 1.5s
      vsync: this,
    );

    // Logo animations (first - 0.0 to 0.4)
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );

    // Text animation (second - 0.2 to 0.6)
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );

    // Background animation (last - 0.4 to 0.8)
    _backgroundFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  void _initializeApp() async {
    // Wait for animation to complete
    await Future.delayed(const Duration(milliseconds: 1200));

    // Initialize authentication
    if (mounted) {
      print('🚀 [SPLASH] Calling initializeAuth...');
      ref.read(authControllerProvider.notifier).initializeAuth();
    } else {
      print('🚀 [SPLASH] Widget not mounted, skipping initializeAuth');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('🚀 [SPLASH] Building SplashPage');
    final authState = ref.watch(authControllerProvider);
    print(
      '🚀 [SPLASH] Auth state: isLoading=${authState.isLoading}, isLoggedIn=${authState.isLoggedIn}, user=${authState.user != null}, error=${authState.errorMessage}',
    );

    // Listen to auth state changes
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      print(
        '🚀 [SPLASH] Auth state changed: previous=${previous?.isLoading}/${previous?.isLoggedIn}, next=${next.isLoading}/${next.isLoggedIn}',
      );
      if (next.isLoading == false) {
        print('🚀 [SPLASH] Auth loading finished, calling _handleAuthResult');
        _handleAuthResult(context, next);
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo with Hero transition
                  Hero(
                    tag: 'app_logo',
                    child: FadeTransition(
                      opacity: _logoFadeAnimation,
                      child: ScaleTransition(
                        scale: _logoScaleAnimation,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.asset(
                              'assets/images/oscar.png',
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // App Name with staggered animation
                  FadeTransition(
                    opacity: _textFadeAnimation,
                    child: Text(
                      'Oscar Duty App',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Loading indicator or error with background fade animation
                  FadeTransition(
                    opacity: _backgroundFadeAnimation,
                    child: Column(
                      children: [
                        if (authState.isLoading) ...[
                          CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary,
                            strokeWidth: 3,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Initializing...',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ] else if (authState.errorMessage != null) ...[
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.error,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Connection Error',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            authState.errorMessage!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  ref
                                      .read(authControllerProvider.notifier)
                                      .initializeAuth();
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                              ),
                              const SizedBox(width: 16),
                              OutlinedButton.icon(
                                onPressed: () {
                                  context.router.push(const LoginRoute());
                                },
                                icon: const Icon(Icons.login),
                                label: const Text('Go to Login'),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleAuthResult(BuildContext context, AuthState authState) {
    print(
      '🚀 [SPLASH] Handling auth result: isLoading=${authState.isLoading}, isLoggedIn=${authState.isLoggedIn}, user=${authState.user != null}, error=${authState.errorMessage}',
    );

    if (authState.errorMessage != null) {
      // Error occurred, show error UI (handled in build method)
      print('🚀 [SPLASH] Auth error occurred: ${authState.errorMessage}');
      return;
    }

    if (authState.isLoggedIn && authState.user != null) {
      // User is logged in, navigate to appropriate dashboard
      print(
        '🚀 [SPLASH] User is logged in, navigating to dashboard for role: ${authState.user!.role}',
      );
      _navigateToDashboard(context, authState.user!);
    } else {
      // User is not logged in, navigate to login
      print('🚀 [SPLASH] User not logged in, navigating to login');
      context.router.replaceAll([const LoginRoute()]);
    }
  }

  void _navigateToDashboard(BuildContext context, User user) {
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (user.role) {
        case AppConstants.supervisorRole:
          context.router.replaceAll([const SupervisorHomeRoute()]);
          break;
        case AppConstants.hodRole:
          context.router.replaceAll([const HodDashboardRoute()]);
          break;
        default:
          // Unknown role, redirect to login
          context.router.replaceAll([const LoginRoute()]);
      }
    });
  }
}
