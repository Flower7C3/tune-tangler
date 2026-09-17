import 'package:hive_ce/hive.dart';
import 'package:record/record.dart';

enum AudioInputDeviceAdapterKey { id, label }

class AudioInputDeviceAdapter extends TypeAdapter<InputDevice> {
  @override
  get typeId => 115;

  @override
  InputDevice read(BinaryReader reader) {
    final data = reader.readMap();
    return InputDevice(
      id: data[AudioInputDeviceAdapterKey.id.toString()],
      label: data[AudioInputDeviceAdapterKey.label.toString()],
    );
  }

  @override
  void write(BinaryWriter writer, InputDevice obj) {
    writer.writeMap({
      AudioInputDeviceAdapterKey.id.toString(): obj.id,
      AudioInputDeviceAdapterKey.label.toString(): obj.label,
    });
  }
}
