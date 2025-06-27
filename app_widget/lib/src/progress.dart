import 'package:flutter/material.dart';

/// A bad but efficient catch all place holder.
class CenteredProgress extends StatelessWidget {
  const CenteredProgress({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

/// Small icon, typically for leading/trailing
class SmallProgress extends StatelessWidget {
  const SmallProgress({super.key});
  @override
  Widget build(BuildContext context) {
    var size = IconTheme.of(context).size!;
    return SizedBox(
      width: size,
      height: size,
      child: Padding(
        padding: EdgeInsets.all(size / 6),
        child: const CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

/// Small icon, typically for leading/trailing
class SmallConnectivityError extends StatelessWidget {
  const SmallConnectivityError({super.key});
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Icon(
      Icons.cloud_off,
      color: theme.brightness == Brightness.light
          ? Colors.grey[300]
          : Colors.grey[700],
    );
  }
}
