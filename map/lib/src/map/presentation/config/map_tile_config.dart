class MapTileConfig {
  final bool show;

  final String urlTemplate;

  final String userAgentPackageName;

  const MapTileConfig({
    this.show = true,
    this.urlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    this.userAgentPackageName = 'com.example.map',
  });
}
