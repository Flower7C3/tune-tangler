import 'package:flutter/material.dart';

import '../config/app_config_fields.dart';
import '../config/app_global_config.dart';
import '../config/app_icon.dart';
import '../config/config_collection.dart';
import '../entity/settings_profile.dart';
import '../helper/ui_helper.dart';
import '../src/generated/app_localizations.dart';
import 'hive_settings_provider.dart';

class SettingProfileWrapper {
  final BuildContext _context;
  final HiveSettingsProvider _settings;
  final AppLocalizations _trans;
  final UIHelper _uiHelper;

  SettingProfileWrapper(this._context, this._trans, this._settings, this._uiHelper);

  List<Widget> toList(SettingsProfile settingsProfile) => [
    ExpansionTile(
      leading: Icon(AppIcon.recordingSettings),
      title: Text(_trans.recording),
      initiallyExpanded: true,
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      expandedAlignment: Alignment.topRight,
      children: [
        _uiHelper.valueIconTile(
          AppIcon.recordingInputDevice,
          _trans.recordingInputDeviceTitle,
          settingsProfile.recordingInputDevice != null
              ? settingsProfile.recordingInputDevice!.label
              : _trans.defaultDevice,
        ),
        _uiHelper.valueIconTile(
          AppIcon.recordingAudioEncoder,
          _trans.recordingAudioEncoderTitle,
          AppGlobalConfig.recordingAudioEncoder.format(settingsProfile.recordingAudioEncoder),
        ),
        _uiHelper.valueIconTile(
          AppIcon.recordingSampleRate,
          _trans.recordingSampleRateTitle,
          AppGlobalConfig.recordingSampleRate.format(settingsProfile.recordingSampleRate),
        ),
        _uiHelper.valueIconTile(
          AppIcon.recordingBitRate,
          _trans.recordingBitRateTitle,
          AppGlobalConfig.recordingBitRate.format(settingsProfile.recordingBitRate),
        ),
        _uiHelper.valueIconTile(
          AppIcon.recordingAudioMode,
          _trans.recordingAudioMode,
          AppGlobalConfig.recordingAudioMode.translate(settingsProfile.recordingAudioModeStereo, trans: _trans),
        ),
        _uiHelper.valueIconTile(
          AppIcon.recordingAutoGain,
          _trans.recordingAutoGain,
          AppGlobalConfig.recordingAutoGain.translate(settingsProfile.recordingAutoGain, trans: _trans),
        ),
        _uiHelper.valueIconTile(
          AppIcon.recordingEchoCancel,
          _trans.recordingEchoCancel,
          AppGlobalConfig.recordingEchoCancel.translate(settingsProfile.recordingEchoCancel, trans: _trans),
        ),
        _uiHelper.valueIconTile(
          AppIcon.recordingNoiseSuppress,
          _trans.recordingNoiseSuppress,
          AppGlobalConfig.recordingNoiseSuppress.translate(settingsProfile.recordingNoiseSuppress, trans: _trans),
        ),
      ],
    ),
    ExpansionTile(
      leading: Icon(AppIcon.screenSettings),
      title: Text(_trans.screen),
      initiallyExpanded: true,
      tilePadding: EdgeInsets.zero,
      // enabled: false,
      children: [
        _uiHelper.valueIconTile(AppIcon.language, _trans.languageVersion, settingsProfile.locale.toString()),
        _uiHelper.valueIconTile(
          AppIcon.screenThemeMode,
          _trans.screenThemeMode,
          AppGlobalConfig.screenThemeMode.translate(settingsProfile.themeMode, trans: _trans),
        ),
        _uiHelper.valueIconTile(
          AppIcon.screenThemeColor,
          _trans.screenThemeColorTitle,
          AppGlobalConfig.userInterfaceColor.translate(settingsProfile.themeSeedColor, trans: _trans),
        ),
        _uiHelper.valueIconTile(
          AppIcon.keepScreenOn,
          _trans.keepScreenOn,
          AppGlobalConfig.keepScreenOn.translate(settingsProfile.wakelockEnabled, trans: _trans),
        ),
      ],
    ),
  ];

  void create() {
    SettingsProfile settingsProfile = SettingsProfile();
    settingsProfile.recordingInputDevice = _settings.getConfig(AppConfigFieldKey.recordingInputDevice);
    settingsProfile.recordingAudioEncoder = _settings.getConfig(AppConfigFieldKey.recordingAudioEncoder);
    settingsProfile.recordingSampleRate = _settings.getConfig(AppConfigFieldKey.recordingSampleRate);
    settingsProfile.recordingBitRate = _settings.getConfig(AppConfigFieldKey.recordingBitRate);
    settingsProfile.recordingAudioModeStereo = _settings.getConfig(AppConfigFieldKey.recordingAudioModeStereo);
    settingsProfile.recordingAutoGain = _settings.getConfig(AppConfigFieldKey.recordingAutoGain);
    settingsProfile.recordingEchoCancel = _settings.getConfig(AppConfigFieldKey.recordingEchoCancel);
    settingsProfile.recordingNoiseSuppress = _settings.getConfig(AppConfigFieldKey.recordingNoiseSuppress);
    settingsProfile.locale = _settings.getConfig(AppConfigFieldKey.locale);
    settingsProfile.themeMode = _settings.getConfig(AppConfigFieldKey.themeMode);
    settingsProfile.themeSeedColor = _settings.getConfig(AppConfigFieldKey.themeSeedColor);
    settingsProfile.wakelockEnabled = _settings.getConfig(AppConfigFieldKey.wakelockEnabled);
    _settings.addProfile(settingsProfile);
    Navigator.pop(_context, 'settingsProfileCreate');
    _uiHelper.toast(_trans.settingsProfileCreated, icon: AppIcon.settingsProfiles);
  }

  void load(SettingsProfile settingsProfile) {
    _settings.setConfig(AppConfigFieldKey.recordingInputDevice, settingsProfile.recordingInputDevice);
    _settings.setConfig(AppConfigFieldKey.recordingAudioEncoder, settingsProfile.recordingAudioEncoder);
    _settings.setConfig(AppConfigFieldKey.recordingSampleRate, settingsProfile.recordingSampleRate);
    _settings.setConfig(AppConfigFieldKey.recordingBitRate, settingsProfile.recordingBitRate);
    _settings.setConfig(AppConfigFieldKey.recordingAudioModeStereo, settingsProfile.recordingAudioModeStereo);
    _settings.setConfig(AppConfigFieldKey.recordingAutoGain, settingsProfile.recordingAutoGain);
    _settings.setConfig(AppConfigFieldKey.recordingEchoCancel, settingsProfile.recordingEchoCancel);
    _settings.setConfig(AppConfigFieldKey.recordingNoiseSuppress, settingsProfile.recordingNoiseSuppress);
    _settings.setConfig(AppConfigFieldKey.locale, settingsProfile.locale);
    _settings.setConfig(AppConfigFieldKey.themeMode, settingsProfile.themeMode);
    _settings.setConfig(AppConfigFieldKey.themeSeedColor, settingsProfile.themeSeedColor);
    _settings.setConfig(AppConfigFieldKey.wakelockEnabled, settingsProfile.wakelockEnabled);
    Navigator.pop(_context, 'settingsProfilesDialog');
    _uiHelper.toast(_trans.settingsProfileLoaded, icon: AppIcon.settingsProfiles);
  }

  void delete(int index) {
    _settings.deleteProfile(index);
    Navigator.pop(_context, 'settingsProfilesDeleteDialog');
    Navigator.pop(_context, 'settingsProfilesDialog');
    _uiHelper.toast(_trans.settingsProfileDeleted, icon: AppIcon.settingsProfiles);
  }

  Text listTitle(SettingsProfile item) =>
      _uiHelper.buildRichText('\$[recordingInputDeviceIcon] \$[recordingInputDeviceValue]', data: _data(item));

  Text listSubtitle(SettingsProfile item) => _uiHelper.buildRichText(
    '\$[recordingAudioEncoderIcon]\$[recordingAudioEncoderValue] \$[recordingSampleRateIcon]\$[recordingSampleRateValue] \$[recordingBitRateIcon]\$[recordingBitRateValue] \n\$[recordingAudioModeIcon]\$[recordingAutoGainIcon]\$[recordingEchoCancelIcon] \$[themeModeIcon]\$[wakelockEnabled] \$[colorIcon]\$[themeSeedColorName] (\$[localeTag])',
    data: _data(item),
  );

  Map<String, dynamic> _data(SettingsProfile item) => {
    'recordingInputDeviceIcon': AppIcon.recordingInputDevice,
    'recordingInputDeviceValue': item.recordingInputDevice != null
        ? item.recordingInputDevice!.label
        : _trans.defaultDevice,
    'recordingAudioEncoderIcon': AppIcon.recordingAudioEncoder,
    'recordingAudioEncoderValue': AppGlobalConfig.recordingAudioEncoder.text(
      item.recordingAudioEncoder,
      domain: ConfigItemPropertyDomain.shortName,
    ),
    'recordingSampleRateIcon': AppIcon.recordingSampleRate,
    'recordingSampleRateValue': AppGlobalConfig.recordingSampleRate.format(item.recordingSampleRate),
    'recordingBitRateIcon': AppIcon.recordingBitRate,
    'recordingBitRateValue': AppGlobalConfig.recordingBitRate.format(item.recordingBitRate),
    'recordingAudioModeIcon': item.recordingAudioModeStereo
        ? AppIcon.recordingAudioModeStereo
        : AppIcon.recordingAudioModeMono,
    'recordingAutoGainIcon': item.recordingAutoGain ? AppIcon.recordingAutoGain : '',
    'recordingEchoCancelIcon': item.recordingEchoCancel ? AppIcon.recordingEchoCancel : '',
    'localeName': AppGlobalConfig.languages.text(item.locale),
    'localeTag': item.locale.toLanguageTag(),
    'themeModeIcon': AppGlobalConfig.screenThemeMode.icon(item.themeMode),
    'themeSeedColorName': AppGlobalConfig.userInterfaceColor.translate(item.themeSeedColor, trans: _trans),
    'wakelockEnabled': item.wakelockEnabled ? AppIcon.keepScreenOnEnabled : '',
    'colorIcon': AppIcon.screenThemeColor,
  };
}
