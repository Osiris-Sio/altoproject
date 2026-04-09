import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altoproject/core/models/contact.dart';
import 'package:altoproject/core/providers/app_providers.dart';
import '../models/message.dart';
import '../notifiers/message_notifier.dart';

export '../models/message.dart';
export '../notifiers/message_notifier.dart' show kMaxMessageLength;

/// Provider de conversation, scopé par contact (autoDispose).
final messageNotifierProvider = StateNotifierProvider.autoDispose
    .family<MessageNotifier, MessageState, Contact>(
  (ref, contact) => MessageNotifier(
    elementApi: ref.watch(elementApiServiceProvider),
    keyStorage: ref.watch(keyStorageProvider),
    storage: ref.watch(messageStorageServiceProvider),
    contact: contact,
  ),
);


