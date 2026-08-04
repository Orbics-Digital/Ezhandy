import 'dart:io';

class ProductImageSlotUpdate {
  const ProductImageSlotUpdate._({
    this.existingUrl,
    this.newFile,
    this.isRemoved = false,
  });

  final String? existingUrl;
  final File? newFile;
  final bool isRemoved;

  factory ProductImageSlotUpdate.keep(String existingUrl) {
    return ProductImageSlotUpdate._(existingUrl: existingUrl);
  }

  factory ProductImageSlotUpdate.upload(File newFile) {
    return ProductImageSlotUpdate._(newFile: newFile);
  }

  factory ProductImageSlotUpdate.remove() {
    return const ProductImageSlotUpdate._(isRemoved: true);
  }
}
