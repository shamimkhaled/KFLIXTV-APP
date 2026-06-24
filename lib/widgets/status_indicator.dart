import 'package:flutter/material.dart';

import '../models/portal.dart';
import '../utils/app_theme.dart';

/// Small colored dot + label showing a portal's last-known reachability.
class StatusIndicator extends StatelessWidget {
  const StatusIndicator({super.key, required this.status, this.compact = false});

  final PortalReachability status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      PortalReachability.online => (AppColors.online, 'Online'),
      PortalReachability.offline => (AppColors.offline, 'Offline'),
      PortalReachability.checking => (AppColors.checking, 'Checking'),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        if (!compact) ...[
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ],
    );
  }
}
