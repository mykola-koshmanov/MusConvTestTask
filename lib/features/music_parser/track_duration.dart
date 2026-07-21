Duration? parseClockDuration(String? value) {
  if (value == null) {
    return null;
  }
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return null;
  }

  final parts = trimmed.split(':');
  if (parts.length < 2 || parts.length > 3) {
    return null;
  }

  final numbers = <int>[];
  for (final part in parts) {
    final parsed = int.tryParse(part.trim());
    if (parsed == null || parsed < 0) {
      return null;
    }
    numbers.add(parsed);
  }

  if (numbers.length == 2) {
    return Duration(minutes: numbers[0], seconds: numbers[1]);
  }
  return Duration(hours: numbers[0], minutes: numbers[1], seconds: numbers[2]);
}

Duration? parseIsoDuration(String? value) {
  if (value == null) {
    return null;
  }
  final match = RegExp(
    r'^PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?$',
  ).firstMatch(value.trim());
  if (match == null) {
    return null;
  }
  final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
  final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
  final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;
  if (hours == 0 && minutes == 0 && seconds == 0) {
    return null;
  }
  return Duration(hours: hours, minutes: minutes, seconds: seconds);
}

String formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);
  final secondsText = seconds.toString().padLeft(2, '0');
  if (hours > 0) {
    final minutesText = minutes.toString().padLeft(2, '0');
    return '$hours:$minutesText:$secondsText';
  }
  return '$minutes:$secondsText';
}
