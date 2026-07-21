import 'package:flutter/foundation.dart';

@immutable
class MusicTrack {
  const MusicTrack({
    required this.position,
    required this.title,
    this.duration,
    this.durationText,
  });

  final int position;
  final String title;
  final Duration? duration;
  final String? durationText;

  bool get hasDuration =>
      durationText != null && durationText!.trim().isNotEmpty;
}
