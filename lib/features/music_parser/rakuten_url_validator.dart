import 'models/collection_type.dart';
import 'parse_failure.dart';
import 'rakuten_link.dart';

sealed class UrlValidationResult {
  const UrlValidationResult();
}

class ValidRakutenUrl extends UrlValidationResult {
  const ValidRakutenUrl(this.link);

  final RakutenLink link;
}

class InvalidRakutenUrl extends UrlValidationResult {
  const InvalidRakutenUrl(this.failure);

  final ParseFailure failure;
}

class RakutenUrlValidator {
  const RakutenUrlValidator();

  static const String _expectedHost = 'music.rakuten.co.jp';
  static const String _linkSegment = 'link';

  UrlValidationResult validate(String rawInput) {
    final trimmed = rawInput.trim();
    if (trimmed.isEmpty) {
      return const InvalidRakutenUrl(EmptyUrlFailure());
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return const InvalidRakutenUrl(InvalidUrlFailure());
    }

    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return const InvalidRakutenUrl(InvalidUrlFailure());
    }

    if (_normalizedHost(uri.host) != _expectedHost) {
      return const InvalidRakutenUrl(UnsupportedDomainFailure());
    }

    final segments = uri.pathSegments
        .where((segment) => segment.isNotEmpty)
        .toList();

    if (segments.length < 3 || segments.first != _linkSegment) {
      return const InvalidRakutenUrl(UnsupportedPathFailure());
    }

    final type = CollectionType.fromPathSegment(segments[1]);
    final id = segments[2];
    if (type == null || id.isEmpty) {
      return const InvalidRakutenUrl(UnsupportedPathFailure());
    }

    final normalizedUrl = Uri(
      scheme: 'https',
      host: _expectedHost,
      pathSegments: [_linkSegment, type.pathSegment, id],
    ).toString();

    return ValidRakutenUrl(
      RakutenLink(
        collectionType: type,
        sourceId: id,
        normalizedUrl: normalizedUrl,
      ),
    );
  }

  String _normalizedHost(String host) {
    final lower = host.toLowerCase();
    return lower.startsWith('www.') ? lower.substring(4) : lower;
  }
}
