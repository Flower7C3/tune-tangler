import 'package:permission_handler/permission_handler.dart';

import '../config/app_global_config.dart';

class PermissionProvider {
  Map<Permission, PermissionStatus> _permissionStatuses = {};

  void init() {
    Map<Permission, PermissionStatus> statuses = {};
    for (var permission in AppGlobalConfig.permissions.values<Permission>()) {
      permission.status.then((status) => statuses[permission] = status);
    }
    _permissionStatuses = statuses;
  }

  PermissionStatus? get(Permission name) => _permissionStatuses[name];

  void set(Permission name, PermissionStatus status) =>
      _permissionStatuses[name] = status;
}
