import 'package:altoproject/features/creating/notifiers/user_notifiers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';

final userProvider = AsyncNotifierProvider<UserNotifiers, User>(
  UserNotifiers.new,
);
