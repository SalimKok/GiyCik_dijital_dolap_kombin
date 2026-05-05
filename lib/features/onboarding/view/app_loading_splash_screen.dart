import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:gircik/features/home/viewmodel/home_viewmodel.dart';

class AppLoadingSplashScreen extends ConsumerStatefulWidget {
  const AppLoadingSplashScreen({super.key});

  @override
  ConsumerState<AppLoadingSplashScreen> createState() => _AppLoadingSplashScreenState();
}

class _AppLoadingSplashScreenState extends ConsumerState<AppLoadingSplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  bool _isTimerDone = false;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack)),
    );

    _animationController.forward();

    // Start a 2.5 second minimum timer
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _isTimerDone = true;
        });
        _checkReady();
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _checkReady() {
    if (!_isTimerDone) return;
    
    // Check if background data loading is done
    final homeState = ref.read(homeViewModelProvider);
    if (!homeState.isLoading) {
      // Proceed to main screen
      ref.read(authViewModelProvider.notifier).setSeenSplash(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final homeState = ref.watch(homeViewModelProvider);
    
    // We listen to the provider to trigger readiness check when loading completes
    ref.listen(homeViewModelProvider, (previous, next) {
      if (previous?.isLoading == true && next.isLoading == false) {
        _checkReady();
      }
    });

    final userName = homeState.userName;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Icon Animation
            ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Text Animation
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Text(
                    'Merhaba $userName',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bugün ne giyeceksin?',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Loading Indicator
            AnimatedOpacity(
              opacity: (homeState.isLoading || !_isTimerDone) ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: _JumpingDots(
                color: theme.colorScheme.primary,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JumpingDots extends StatefulWidget {
  final Color color;
  final double size;
  
  const _JumpingDots({this.color = Colors.black, this.size = 12});

  @override
  State<_JumpingDots> createState() => _JumpingDotsState();
}

class _JumpingDotsState extends State<_JumpingDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            double offset = 0.0;
            // Delay each dot by 0.15 of the animation duration
            double delay = index * 0.15;
            double t = (_controller.value - delay);
            if (t < 0) t += 1.0;
            
            // Jump happens in the first 40% of the cycle
            if (t < 0.4) {
              // Map t from [0, 0.4] to [0, pi]
              double normalizedT = t / 0.4;
              offset = -12.0 * math.sin(normalizedT * math.pi);
            }
            
            return Transform.translate(
              offset: Offset(0, offset),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
