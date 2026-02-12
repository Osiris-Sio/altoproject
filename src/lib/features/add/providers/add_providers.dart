import 'package:provider/provider.dart';
import '../notifiers/add_user_notifier.dart';

/// Providers pour la feature Add
final addFeatureProviders = [
  ChangeNotifierProvider(
    create: (_) => AddUserNotifier(),
  ),
];

