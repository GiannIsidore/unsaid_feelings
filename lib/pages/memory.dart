// import 'dart:typed_data';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';

// class MemoryImageProvider extends ImageProvider<MemoryImageProvider> {
//   final Uint8List bytes;

//   MemoryImageProvider(this.bytes);

//   @override
//   ImageStreamCompleter load(MemoryImageProvider key, ImageDecoderCallback decode) {
//     return OneFrameImageStreamCompleter(
//       Future<ImageInfo>.sync(() => decode()),
//     );
//   }

//   @override
//   Future<MemoryImageProvider> obtainKey(ImageConfiguration configuration) {
//     return SynchronousFuture<MemoryImageProvider>(this);
//   }

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     return other is MemoryImageProvider && listEquals(other.bytes, bytes);
//   }

//   @override
//   int get hashCode => bytes.hashCode;
// }