import 'package:flutter/material.dart';
import 'package:hms/constants/features_toggle.dart';
import 'package:hms/fireStore_service/session_manager.dart';
import 'package:hms/service_utilities/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Map<String, Future<void> Function(BuildContext)> specialActions = {
  'Logout': (BuildContext context) async {
    // Your logout logic:
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    SessionManager().stopTracking();

    // If you have state to update, consider using Provider or setState at widget level

    // Navigate to login and clear stack
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  },
};

Future<List<Widget>> buildDrawerOptions(
  BuildContext context,
  Color contentColor,
  bool isDark,
) async {
  final List<Widget> options = [];

  final prefs = await SharedPreferences.getInstance();
  final userRole = prefs.getString('userlevel') ?? 'Guest';
  final featureMap = await FeatureToggles.getFeaturesForUser(userRole);

  for (final entry in featureMap.entries) {
    final feature = entry.key;
    final enabled = entry.value;
    if (!enabled) continue;

    if (featureToRoute.containsKey(feature)) {
      final route = featureToRoute[feature]!;

      options.add(
        ListTile(
          leading: Icon(getIconForFeature(feature), color: contentColor),
          title: Text(
            feature,
            style: TextStyle(
              color: contentColor,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              shadows: [
                Shadow(
                  blurRadius: 2,
                  offset: Offset(1, 1),
                  color: isDark ? Colors.black45 : Colors.white60,
                ),
              ],
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).pushNamed(route);
          },
        ),
      );
    } else if (specialActions.containsKey(feature)) {
      options.add(
        ListTile(
          leading: Icon(getIconForFeature(feature), color: contentColor),
          title: Text(
            feature,
            style: TextStyle(
              color: contentColor,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              shadows: [
                Shadow(
                  blurRadius: 2,
                  offset: Offset(1, 1),
                  color: isDark ? Colors.black45 : Colors.white60,
                ),
              ],
            ),
          ),
          onTap: () async {
            Navigator.pop(context);
            await specialActions[feature]!(context);
          },
        ),
      );
    }
  }

  return options;
}
