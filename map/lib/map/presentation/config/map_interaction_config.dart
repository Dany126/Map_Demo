import 'package:flutter_map/flutter_map.dart';

class MapInteractionConfig {
  final bool enableDrag;
  final bool enablePinchMove;
  final bool enablePinchZoom;
  final bool enableDoubleTapZoom;
  final bool enableScrollWheelZoom;
  final bool enableRotate;

  const MapInteractionConfig({
    this.enableDrag = true,
    this.enablePinchMove = true,
    this.enablePinchZoom = true,
    this.enableDoubleTapZoom = true,
    this.enableScrollWheelZoom = true,
    this.enableRotate = true,
  });

  InteractionOptions toInteractionOptions() {
    int flags = InteractiveFlag.none;
    if (enableDrag) flags |= InteractiveFlag.drag;
    if (enablePinchMove) flags |= InteractiveFlag.pinchMove;
    if (enablePinchZoom) flags |= InteractiveFlag.pinchZoom;
    if (enableDoubleTapZoom) flags |= InteractiveFlag.doubleTapZoom;
    if (enableScrollWheelZoom) flags |= InteractiveFlag.scrollWheelZoom;
    if (enableRotate) flags |= InteractiveFlag.rotate;

    return InteractionOptions(flags: flags);
  }
}
