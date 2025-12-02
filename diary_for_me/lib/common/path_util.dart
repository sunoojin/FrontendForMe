// lib/common/path_util.dart
bool isNetworkUrl(String path) {
  return path.startsWith('http://') || path.startsWith('https://');
}

bool isAssetPath(String path) {
  return path.startsWith('assets://') || path.startsWith('asset:');
}

String assetPathToAssetFile(String assetPath) {
  if (assetPath.startsWith('assets://')) {
    return assetPath.replaceFirst('assets://', 'assets/');
  }
  return assetPath;
}
