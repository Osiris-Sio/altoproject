import 'package:provider/provider.dart';
import '../notifiers/profile_notifier.dart';

/// Providers pour la feature Profile
final profileFeatureProviders = [
  ChangeNotifierProvider(
    create: (_) => ProfileNotifier(),
  ),
];

