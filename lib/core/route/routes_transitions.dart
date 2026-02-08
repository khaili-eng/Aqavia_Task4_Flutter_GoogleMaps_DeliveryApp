import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class RouteTransitions{
  //fade transiyyions fadeIn/fadeOut
  static CustomTransitionPage fadeTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );
      },
    );
  }
  //slide transition
  static CustomTransitionPage slideTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
    Offset begin = const Offset(1.0, 0.0),
  }){
    return CustomTransitionPage(
        child: child, transitionsBuilder: (context,animation,secondaryAnimation,child){
      return SlideTransition(
        position: Tween<Offset>(
          begin: begin,
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        )),
        child: child,
      );
    });
  }
//scale transitions
  static CustomTransitionPage scaleTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }){
    return CustomTransitionPage(
        child: child,
        transitionsBuilder: (context, animation, secondaryAnimation, child){
          return ScaleTransition(
            scale: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutBack,
            )),
            child: child,);
        });
  }
}