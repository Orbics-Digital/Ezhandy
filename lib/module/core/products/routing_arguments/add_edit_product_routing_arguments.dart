import 'package:ezhandy_user/module/core/products/model/product_model.dart';

class AddEditProductRoutingArgument {
  final String? type;
  final ProductModel? product;

  AddEditProductRoutingArgument({
    required this.type,
    this.product,
  });
}
