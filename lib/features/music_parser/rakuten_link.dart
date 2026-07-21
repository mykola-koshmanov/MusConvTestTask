import 'package:flutter/foundation.dart';

import 'models/collection_type.dart';

@immutable
class RakutenLink {
  const RakutenLink({
    required this.collectionType,
    required this.sourceId,
    required this.normalizedUrl,
  });

  final CollectionType collectionType;
  final String sourceId;
  final String normalizedUrl;
}
