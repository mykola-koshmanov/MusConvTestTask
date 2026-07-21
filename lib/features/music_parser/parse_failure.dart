sealed class ParseFailure {
  const ParseFailure(this.message);

  final String message;
}

class EmptyUrlFailure extends ParseFailure {
  const EmptyUrlFailure() : super('Enter a Rakuten Music URL.');
}

class InvalidUrlFailure extends ParseFailure {
  const InvalidUrlFailure() : super('This does not look like a valid URL.');
}

class UnsupportedDomainFailure extends ParseFailure {
  const UnsupportedDomainFailure()
    : super('Only music.rakuten.co.jp links are supported.');
}

class UnsupportedPathFailure extends ParseFailure {
  const UnsupportedPathFailure()
    : super('This Rakuten Music link type is not supported.');
}

class NoConnectionFailure extends ParseFailure {
  const NoConnectionFailure()
    : super('Unable to load the page. Check your connection and try again.');
}

class TimeoutFailure extends ParseFailure {
  const TimeoutFailure()
    : super('The request timed out. Please try again.');
}

class PageUnavailableFailure extends ParseFailure {
  const PageUnavailableFailure()
    : super('This page is unavailable. It may have been removed.');
}

class CollectionNotFoundFailure extends ParseFailure {
  const CollectionNotFoundFailure()
    : super('Music information could not be extracted from this page.');
}

class ParsingFailure extends ParseFailure {
  const ParsingFailure()
    : super('Something went wrong while reading this page. Please try again.');
}
