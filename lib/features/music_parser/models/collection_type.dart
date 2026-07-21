enum CollectionType {
  album,
  playlist;

  String get label {
    switch (this) {
      case CollectionType.album:
        return 'Album';
      case CollectionType.playlist:
        return 'Playlist';
    }
  }

  String get pathSegment {
    switch (this) {
      case CollectionType.album:
        return 'album';
      case CollectionType.playlist:
        return 'playlist';
    }
  }

  static CollectionType? fromPathSegment(String segment) {
    for (final type in CollectionType.values) {
      if (type.pathSegment == segment) {
        return type;
      }
    }
    return null;
  }
}
