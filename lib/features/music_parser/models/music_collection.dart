import 'package:flutter/foundation.dart';

import 'collection_type.dart';
import 'music_track.dart';

@immutable
class MusicCollection {
  const MusicCollection({
    required this.sourceUrl,
    required this.sourceId,
    required this.collectionType,
    required this.title,
    this.artistName,
    this.imageUrl,
    this.description,
    this.releaseYear,
    this.trackCount,
    this.tracks = const [],
  });

  final String sourceUrl;
  final String sourceId;
  final CollectionType collectionType;
  final String title;
  final String? artistName;
  final String? imageUrl;
  final String? description;
  final int? releaseYear;
  final int? trackCount;
  final List<MusicTrack> tracks;

  int get resolvedTrackCount => trackCount ?? tracks.length;

  bool get hasArtist => artistName != null && artistName!.trim().isNotEmpty;

  bool get hasDescription =>
      description != null && description!.trim().isNotEmpty;

  bool get hasImage => imageUrl != null && imageUrl!.trim().isNotEmpty;

  bool get hasReleaseYear => releaseYear != null;

  bool get hasTracks => tracks.isNotEmpty;
}
