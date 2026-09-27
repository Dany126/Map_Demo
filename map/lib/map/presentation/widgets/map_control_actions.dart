class MapControlActions {
  final void Function() zoomIn;
  final void Function() zoomOut;
  final void Function() locateMe;
  final void Function() fitAll;
  final void Function() fitRoute;

  final bool canFitRoute;

  const MapControlActions({
    required this.zoomIn,
    required this.zoomOut,
    required this.locateMe,
    required this.fitAll,
    required this.fitRoute,
    required this.canFitRoute,
  });
}
