import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:matrix/matrix_api_lite/utils/logs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fluffychat/utils/platform_infos.dart';

enum AppSettings<T> {
  textMessageMaxLength<int>('textMessageMaxLength', 16384),
  audioRecordingNumChannels<int>('audioRecordingNumChannels', 1),
  audioRecordingAutoGain<bool>('audioRecordingAutoGain', true),
  audioRecordingEchoCancel<bool>('audioRecordingEchoCancel', false),
  audioRecordingNoiseSuppress<bool>('audioRecordingNoiseSuppress', true),
  audioRecordingBitRate<int>('audioRecordingBitRate', 64000),
  audioRecordingSamplingRate<int>('audioRecordingSamplingRate', 44100),
  showNoGoogle<bool>('chat.fluffy.show_no_google', false),
  unifiedPushRegistered<bool>('chat.fluffy.unifiedpush.registered', false),
  unifiedPushEndpoint<String>('chat.fluffy.unifiedpush.endpoint', ''),
  pushNotificationsGatewayUrl<String>(
    'pushNotificationsGatewayUrl',
    'https://push.fluffychat.im/_matrix/push/v1/notify',
  ),
  pushNotificationsPusherFormat<String>(
    'pushNotificationsPusherFormat',
    'event_id_only',
  ),
  renderHtml<bool>('chat.fluffy.renderHtml', true),
  fontSizeFactor<double>('chat.fluffy.font_size_factor', 1.0),
  hideRedactedEvents<bool>('chat.fluffy.hideRedactedEvents', false),
  hideUnknownEvents<bool>('chat.fluffy.hideUnknownEvents', true),
  separateChatTypes<bool>('chat.fluffy.separateChatTypes', false),
  autoplayImages<bool>('chat.fluffy.autoplay_images', true),
  sendTypingNotifications<bool>('chat.fluffy.send_typing_notifications', true),
  sendPublicReadReceipts<bool>('chat.fluffy.send_public_read_receipts', true),
  swipeRightToLeftToReply<bool>('chat.fluffy.swipeRightToLeftToReply', true),
  sendOnEnter<bool>('chat.fluffy.send_on_enter', false),
  showPresences<bool>('chat.fluffy.show_presences', true),
  displayNavigationRail<bool>('chat.fluffy.display_navigation_rail', false),
  experimentalVoip<bool>('chat.fluffy.experimental_voip', false),
  shareKeysWith<String>('chat.fluffy.share_keys_with_2', 'all'),
  noEncryptionWarningShown<bool>(
    'chat.fluffy.no_encryption_warning_shown',
    false,
  ),
  displayChatDetailsColumn(
    'chat.fluffy.display_chat_details_column',
    false,
  ),
  // AppConfig-mirrored settings
  applicationName<String>('chat.fluffy.application_name', 'FluffyChat'),
  defaultHomeserver<String>('chat.fluffy.default_homeserver', 'matrix.org'),
  // colorSchemeSeed stored as ARGB int
  colorSchemeSeedInt<int>(
    'chat.fluffy.color_scheme_seed',
    0xFF5625BA,
  ),
  colorSchemePrimary<int>(
    'chat.fluffy.color_scheme_primary',
    0xFFFF9DFB,
  ),
  colorSchemeOnPrimary<int>(
    'chat.fluffy.color_scheme_on_primary',
    0xFF3E478E,
  ),
  colorSchemePrimaryContainer<int>(
    'chat.fluffy.color_scheme_primary_container',
    0xFFFF9DFB,
  ),
  colorSchemeOnPrimaryContainer<int>(
    'chat.fluffy.color_scheme_on_primary_container',
    0xFFFF9DFB,
  ),
  colorSchemeOnPrimaryContainerDark<int>(
    'chat.fluffy.color_scheme_on_primary_container_dark',
    0xFF3E478E,
  ),
  colorSchemeSecondary<int>(
    'chat.fluffy.color_scheme_secondary',
    0xFFD2BBFA,
  ),
  colorSchemeOnSecondary<int>(
    'chat.fluffy.color_scheme_on_secondary',
    0xFF3E478E,
  ),
  colorSchemeSecondaryContainer<int>(
    'chat.fluffy.color_scheme_secondary_container',
    0x40d5befd,
  ),
  colorSchemeOnSecondaryContainer<int>(
    'chat.fluffy.color_scheme_on_secondary_container',
    0xFF3E478E,
  ),
  colorSchemeOnSecondaryContainerDark<int>(
    'chat.fluffy.color_scheme_on_secondary_container_dark',
    0xFFD2BBFA,
  ),
  colorSchemeTertiary<int>(
    'chat.fluffy.color_scheme_tertiary',
    0xFFD2BBFA,
  ),
  colorSchemeOnTertiary<int>(
    'chat.fluffy.color_scheme_on_tertiary',
    0xFF3E478E,
  ),
  colorSchemeTertiaryContainer<int>(
    'chat.fluffy.color_scheme_tertiary_container',
    0x40272e5a,
  ),
  colorSchemeOnTertiaryContainer<int>(
    'chat.fluffy.color_scheme_on_tertiary_container',
    0x40272e5a,
  ),
  colorSchemeSurface<int>(
    'chat.fluffy.color_scheme_surface',
    0x00FFFFFF,
  ),
  colorSchemeSurfaceDark<int>(
    'chat.fluffy.color_scheme_surface_dark',
    0x001F2345,
  ),
  colorSchemeOnSurface<int>(
    'chat.fluffy.color_scheme_on_surface',
    0xFF3E478E,
  ),
  colorSchemeOnSurfaceDark<int>(
    'chat.fluffy.color_scheme_on_surface_dark',
    0xFFFFFFFF,
  ),
  colorSchemeSurfaceBright<int>(
    'chat.fluffy.color_scheme_surface_bright',
    0xFFFFFFFF,
  ),
  colorSchemeSurfaceBrightDark<int>(
    'chat.fluffy.color_scheme_surface_bright_dark',
    0xFF252B57,
  ),
  colorSchemeSurfaceDim<int>(
    'chat.fluffy.color_scheme_surface_dim',
    0x001F2345,
  ),
  colorSchemeSurfaceContainer<int>(
    'chat.fluffy.color_scheme_surface_container',
    0x40FFFFFF,
  ),
  colorSchemeSurfaceContainerLow<int>(
    'chat.fluffy.color_scheme_surface_container_low',
    0x40FFFFFF,
  ),
  colorSchemeSurfaceContainerLowest<int>(
    'chat.fluffy.color_scheme_surface_container_lowest',
    0x40FFFFFF,
  ),
  colorSchemeSurfaceContainerHigh<int>(
    'chat.fluffy.color_scheme_surface_container_high',
    0x40FFFFFF,
  ),
  colorSchemeSurfaceContainerHighest<int>(
    'chat.fluffy.color_scheme_surface_container_highest',
    0x40FFFFFF,
  ),
  enableSoftLogout<bool>('chat.fluffy.enable_soft_logout', false);

  final String key;
  final T defaultValue;

  const AppSettings(this.key, this.defaultValue);

  static SharedPreferences get store => _store!;
  static SharedPreferences? _store;

  static Future<SharedPreferences> init({loadWebConfigFile = true}) async {
    if (AppSettings._store != null) return AppSettings.store;

    final store = AppSettings._store = await SharedPreferences.getInstance();

    // Migrate wrong datatype for fontSizeFactor
    final fontSizeFactorString =
        Result(() => store.getString(AppSettings.fontSizeFactor.key))
            .asValue
            ?.value;
    if (fontSizeFactorString != null) {
      Logs().i('Migrate wrong datatype for fontSizeFactor!');
      await store.remove(AppSettings.fontSizeFactor.key);
      final fontSizeFactor = double.tryParse(fontSizeFactorString);
      if (fontSizeFactor != null) {
        await store.setDouble(AppSettings.fontSizeFactor.key, fontSizeFactor);
      }
    }

    if (store.getBool(AppSettings.sendOnEnter.key) == null) {
      await store.setBool(AppSettings.sendOnEnter.key, !PlatformInfos.isMobile);
    }
    if (kIsWeb && loadWebConfigFile) {
      try {
        final configJsonString =
            utf8.decode((await http.get(Uri.parse('config.json'))).bodyBytes);
        final configJson =
            json.decode(configJsonString) as Map<String, Object?>;
        for (final setting in AppSettings.values) {
          if (store.get(setting.key) != null) continue;
          final configValue = configJson[setting.name];
          if (configValue == null) continue;
          if (configValue is bool) {
            await store.setBool(setting.key, configValue);
          }
          if (configValue is String) {
            await store.setString(setting.key, configValue);
          }
          if (configValue is int) {
            await store.setInt(setting.key, configValue);
          }
          if (configValue is double) {
            await store.setDouble(setting.key, configValue);
          }
        }
      } on FormatException catch (_) {
        Logs().v('[ConfigLoader] config.json not found');
      } catch (e) {
        Logs().v('[ConfigLoader] config.json not found', e);
      }
    }

    return store;
  }
}

extension AppSettingsBoolExtension on AppSettings<bool> {
  bool get value {
    final value = Result(() => AppSettings.store.getBool(key));
    final error = value.asError;
    if (error != null) {
      Logs().e(
        'Unable to fetch $key from storage. Removing entry...',
        error.error,
        error.stackTrace,
      );
    }
    return value.asValue?.value ?? defaultValue;
  }

  Future<void> setItem(bool value) => AppSettings.store.setBool(key, value);
}

extension AppSettingsStringExtension on AppSettings<String> {
  String get value {
    final value = Result(() => AppSettings.store.getString(key));
    final error = value.asError;
    if (error != null) {
      Logs().e(
        'Unable to fetch $key from storage. Removing entry...',
        error.error,
        error.stackTrace,
      );
    }
    return value.asValue?.value ?? defaultValue;
  }

  Future<void> setItem(String value) => AppSettings.store.setString(key, value);
}

extension AppSettingsIntExtension on AppSettings<int> {
  int get value {
    final value = Result(() => AppSettings.store.getInt(key));
    final error = value.asError;
    if (error != null) {
      Logs().e(
        'Unable to fetch $key from storage. Removing entry...',
        error.error,
        error.stackTrace,
      );
    }
    return value.asValue?.value ?? defaultValue;
  }

  Future<void> setItem(int value) => AppSettings.store.setInt(key, value);
}

extension AppSettingsDoubleExtension on AppSettings<double> {
  double get value {
    final value = Result(() => AppSettings.store.getDouble(key));
    final error = value.asError;
    if (error != null) {
      Logs().e(
        'Unable to fetch $key from storage. Removing entry...',
        error.error,
        error.stackTrace,
      );
    }
    return value.asValue?.value ?? defaultValue;
  }

  Future<void> setItem(double value) => AppSettings.store.setDouble(key, value);
}
