import '../controllers/delivery_controller.dart';
import '../controllers/material_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/supplier_controller.dart';

class AppData {
  static final MaterialController materialController = MaterialController();
  static final ProductController productController = ProductController();
  static final DeliveryController deliveryController = DeliveryController();
  static final SupplierController supplierController = SupplierController();
}
