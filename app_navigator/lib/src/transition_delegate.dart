import 'package:flutter/material.dart';

/// No animation delegate.
class NoAnimationTransitionDelegate extends TransitionDelegate<void> {
  /// No animation delegate.
  const NoAnimationTransitionDelegate();
  @override
  Iterable<RouteTransitionRecord> resolve({
    required List<RouteTransitionRecord> newPageRouteHistory,
    required Map<RouteTransitionRecord?, RouteTransitionRecord>
    locationToExitingPageRoute,
    Map<RouteTransitionRecord?, List<RouteTransitionRecord>>?
    pageRouteToPagelessRoutes,
  }) {
    final results = <RouteTransitionRecord>[];

    for (final pageRoute in newPageRouteHistory) {
      if (pageRoute.isWaitingForEnteringDecision) {
        pageRoute.markForAdd();
      }
      results.add(pageRoute);
    }
    for (final exitingPageRoute in locationToExitingPageRoute.values) {
      if (exitingPageRoute.isWaitingForExitingDecision) {
        exitingPageRoute.markForComplete();
        final pagelessRoutes = pageRouteToPagelessRoutes![exitingPageRoute];
        if (pagelessRoutes != null) {
          for (final pagelessRoute in pagelessRoutes) {
            pagelessRoute.markForComplete();
          }
        }
      }
      results.add(exitingPageRoute);
    }
    return results;
  }
}
