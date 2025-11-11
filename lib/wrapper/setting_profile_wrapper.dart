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

  Widget _tile(IconData icon, dynamic value) => _uiHelper.statusIconRow(
        icon,
        value,
        separatorSize: UIHelper.gridGap * 2,
        iconSize: Theme.of(_context).textTheme.bodyLarge!.fontSize! * UIHelper.iconSizeMultiplier,
        fontSize: Theme.of(_context).textTheme.bodyLarge!.fontSize!,
      );

  List<Widget> toList(SettingsProfile settingsProfile) => [
        ExpansionTile(
          leading: Icon(AppIcon.recordingSettings),
          title: Text(_trans.recording),
          initiallyExpanded: true,
          // enabled: false,
          children: [
            _tile(
              AppIcon.recordingInputDevice,
              _trans.recordingInputDeviceValue(
                  settingsProfile.recordingInputDevice != null ? settingsProfile.recordingInputDevice!.label : _trans.defaultDevice),
            ),
            _tile(
              AppIcon.recordingAudioEncoder,
              _trans.recordingAudioEncoderValue(AppGlobalConfig.recordingAudioEncoder.format(settingsProfile.recordingAudioEncoder)),
            ),
            _tile(
              AppIcon.recordingSampleRate,
              _trans.recordingSampleRateValue(AppGlobalConfig.recordingSampleRate.format(settingsProfile.recordingSampleRate)),
            ),
            _tile(
              AppIcon.recordingBitRate,
              _trans.recordingBitRateValue(AppGlobalConfig.recordingBitRate.format(settingsProfile.recordingBitRate)),
            ),
            _tile(
              AppIcon.recordingAudioMode,
              _trans.recordingAudioModeValue(AppGlobalConfig.recordingAudioMode.translate(settingsProfile.recordingAudioModeStereo, trans: _trans)),
            ),
            _tile(
              AppIcon.recordingAutoGain,
              _trans.recordingAutoGainValue(AppGlobalConfig.recordingAutoGain.translate(settingsProfile.recordingAutoGain, trans: _trans)),
            ),
            _tile(
              AppIcon.recordingEchoCancel,
              _trans.recordingEchoCancelValue(AppGlobalConfig.recordingEchoCancel.translate(settingsProfile.recordingEchoCancel, trans: _trans)),
            ),
            _tile(
              AppIcon.recordingNoiseSuppress,
              _trans.recordingNoiseSuppressValue(
                  AppGlobalConfig.recordingNoiseSuppress.translate(settingsProfile.recordingNoiseSuppress, trans: _trans)),
            ),
          ],
        ),
        ExpansionTile(
          leading: Icon(AppIcon.screenSettings),
          title: Text(_trans.screen),
          initiallyExpanded: true,
          // enabled: false,
          children: [
            _tile(
              AppIcon.language,
              _trans.languageVersionValue(settingsProfile.locale.toString()),
            ),
            _tile(
              AppIcon.screenThemeMode,
              _trans.screenThemeModeValue(AppGlobalConfig.screenThemeMode.translate(settingsProfile.themeMode, trans: _trans)),
            ),
            _tile(
              AppIcon.screenThemeColor,
              _trans.screenThemeColorValue(AppGlobalConfig.userInterfaceColor.translate(settingsProfile.themeSeedColor, trans: _trans)),
            ),
            _tile(
              AppIcon.keepScreenOn,
              _trans.keepScreenOnValue(AppGlobalConfig.keepScreenOn.translate(settingsProfile.wakelockEnabled, trans: _trans)),
            ),
            _tile(
              AppIcon.gridRowsAmount,
              _trans.gridRowsAmountValue(AppGlobalConfig.gridRows.format(settingsProfile.gridRowsAmount)),
            ),
            _tile(
              AppIcon.gridColsAmount,
              _trans.gridColsAmountValue(AppGlobalConfig.gridCols.format(settingsProfile.gridColsAmount)),
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
    settingsProfile.gridRowsAmount = _settings.getConfig(AppConfigFieldKey.gridRowsAmount);
    settingsProfile.gridColsAmount = _settings.getConfig(AppConfigFieldKey.gridColsAmount);
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
    _settings.setConfig(AppConfigFieldKey.gridRowsAmount, settingsProfile.gridRowsAmount);
    _settings.setConfig(AppConfigFieldKey.gridColsAmount, settingsProfile.gridColsAmount);
    Navigator.pop(_context, 'settingsProfilesDialog');
    _uiHelper.toast(_trans.settingsProfileLoaded, icon: AppIcon.settingsProfiles);
  }

  void delete(int index) {
    _settings.deleteProfile(index);
    Navigator.pop(_context, 'settingsProfilesDeleteDialog');
    Navigator.pop(_context, 'settingsProfilesDialog');
    _uiHelper.toast(_trans.settingsProfileDeleted, icon: AppIcon.settingsProfiles);
  }

  Text listTitle(SettingsProfile item) => _uiHelper.buildRichText(
      '\$[recordingInputDeviceIcon] \$[recordingInputDeviceValue]',
      data: _data(item));
  Text listSubtitle(SettingsProfile item) => _uiHelper.buildRichText(
      '\$[recordingAudioEncoderIcon]\$[recordingAudioEncoderValue] \$[recordingSampleRateIcon]\$[recordingSampleRateValue] \$[recordingBitRateIcon]\$[recordingBitRateValue] \n\$[recordingAudioModeIcon]\$[recordingAutoGainIcon]\$[recordingEchoCancelIcon] \$[themeModeIcon]\$[wakelockEnabled] \$[gridIcon]\$[gridRowsAmount]x\$[gridColsAmount] \$[colorIcon]\$[themeSeedColorName] (\$[localeTag])',
      data: _data(item));

  Map<String, dynamic> _data(SettingsProfile item) => {
        'recordingInputDeviceIcon': AppIcon.recordingInputDevice,
        'recordingInputDeviceValue': item.recordingInputDevice != null ? item.recordingInputDevice!.label : _trans.defaultDevice,
        'recordingAudioEncoderIcon': AppIcon.recordingAudioEncoder,
        'recordingAudioEncoderValue':
            AppGlobalConfig.recordingAudioEncoder.text(item.recordingAudioEncoder, domain: ConfigItemPropertyDomain.shortName),
        'recordingSampleRateIcon': AppIcon.recordingSampleRate,
        'recordingSampleRateValue': AppGlobalConfig.recordingSampleRate.format(item.recordingSampleRate),
        'recordingBitRateIcon': AppIcon.recordingBitRate,
        'recordingBitRateValue': AppGlobalConfig.recordingBitRate.format(item.recordingBitRate),
        'recordingAudioModeIcon': item.recordingAudioModeStereo ? AppIcon.recordingAudioModeStereo : AppIcon.recordingAudioModeMono,
        'recordingAutoGainIcon': item.recordingAutoGain ? AppIcon.recordingAutoGain : '',
        'recordingEchoCancelIcon': item.recordingEchoCancel ? AppIcon.recordingEchoCancel : '',
        'localeName': AppGlobalConfig.languages.text(item.locale),
        'localeTag': item.locale.toLanguageTag(),
        'themeModeIcon': AppGlobalConfig.screenThemeMode.icon(item.themeMode),
        'themeSeedColorName': AppGlobalConfig.userInterfaceColor.translate(item.themeSeedColor, trans: _trans),
        'wakelockEnabled': item.wakelockEnabled ? AppIcon.keepScreenOnEnabled : '',
        'colorIcon': AppIcon.screenThemeColor,
        'gridIcon': AppIcon.grid,
        'gridRowsAmount': item.gridRowsAmount,
        'gridColsAmount': item.gridColsAmount,
      };
}
