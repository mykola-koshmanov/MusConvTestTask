import 'dart:convert';

import 'package:html/dom.dart';

import '../models/music_collection.dart';
import '../models/music_track.dart';
import '../rakuten_link.dart';
import '../track_duration.dart';
import 'parse_strategy.dart';

class JsonLdStrategy extends ParseStrategy {
  const JsonLdStrategy();

  static const _collectionTypes = {
    'MusicAlbum',
    'MusicPlaylist',
    'MusicRelease',
  };

  @override
  MusicCollection? extract(Document document, RakutenLink link) {
    final scripts = document.querySelectorAll(
      'script[type="application/ld+json"]',
    );

    for (final script in scripts) {
      final raw = script.text.trim();
      if (raw.isEmpty) {
        continue;
      }

      final Object? decoded;
      try {
        decoded = jsonDecode(raw);
      } on FormatException {
        continue;
      }

      final node = _findCollectionNode(decoded);
      if (node == null) {
        continue;
      }

      final title = _asString(node['name']);
      if (title == null) {
        continue;
      }

      return MusicCollection(
        sourceUrl: link.normalizedUrl,
        sourceId: link.sourceId,
        collectionType: link.collectionType,
        title: title,
        artistName: _asString(_asMap(node['byArtist'])?['name']),
        imageUrl: _pickImage(node['image']),
        description: _asString(node['description']),
        trackCount: _asInt(node['numTracks']),
        tracks: _parseTracks(node['track']),
      );
    }
    return null;
  }

  Map<String, Object?>? _findCollectionNode(Object? value) {
    if (value is List) {
      for (final entry in value) {
        final found = _findCollectionNode(entry);
        if (found != null) {
          return found;
        }
      }
      return null;
    }

    final map = _asMap(value);
    if (map == null) {
      return null;
    }

    if (_matchesCollectionType(map['@type'])) {
      return map;
    }

    final graph = map['@graph'];
    if (graph != null) {
      return _findCollectionNode(graph);
    }
    return null;
  }

  bool _matchesCollectionType(Object? type) {
    if (type is String) {
      return _collectionTypes.contains(type);
    }
    if (type is List) {
      return type.any((entry) => _collectionTypes.contains(entry));
    }
    return false;
  }

  List<MusicTrack> _parseTracks(Object? value) {
    final items = _trackItems(value);
    if (items == null) {
      return const [];
    }

    final tracks = <MusicTrack>[];
    for (var index = 0; index < items.length; index++) {
      final element = _asMap(items[index]);
      if (element == null) {
        continue;
      }
      final recording = _asMap(element['item']) ?? element;
      final title = _asString(recording['name']);
      if (title == null) {
        continue;
      }
      final position = _asInt(element['position']) ?? index + 1;
      final duration = parseIsoDuration(_asString(recording['duration']));
      tracks.add(
        MusicTrack(
          position: position,
          title: title,
          duration: duration,
          durationText: duration == null ? null : formatDuration(duration),
        ),
      );
    }
    return tracks;
  }

  List<Object?>? _trackItems(Object? value) {
    final map = _asMap(value);
    if (map != null) {
      final elements = map['itemListElement'];
      if (elements is List) {
        return elements;
      }
    }
    if (value is List) {
      return value;
    }
    return null;
  }

  String? _pickImage(Object? value) {
    if (value is String) {
      return _asString(value);
    }
    if (value is List && value.isNotEmpty) {
      return _pickImage(value.first);
    }
    final map = _asMap(value);
    if (map != null) {
      return _asString(map['url']);
    }
    return null;
  }

  Map<String, Object?>? _asMap(Object? value) {
    if (value is Map) {
      return value.cast<String, Object?>();
    }
    return null;
  }

  String? _asString(Object? value) {
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return null;
  }

  int? _asInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value.trim());
    }
    return null;
  }
}
