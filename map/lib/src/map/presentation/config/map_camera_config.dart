class MapCameraConfig {
  final double initialZoom;
  final double minZoom;
  final double maxZoom;

  const MapCameraConfig({
    this.initialZoom = 16,
    this.minZoom = 3,
    this.maxZoom = 19,
  });
}
