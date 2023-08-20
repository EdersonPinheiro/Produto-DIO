//import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../db/db.dart';
import '../../model/product.dart';
import 'create_product_page.dart';
import 'edit_product_page.dart';

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final db = DB();
  late final Uint8List imageBytes;
  bool isLoading = false;
  final products = <Product>[].obs;

  @override
  void initState() {
    super.initState();
    getProductsDB();
  }

  Future<void> getProductsDB() async {
    products.value = await db.getProductsDB();
    for (var element in products) {
      element.name;
    }
    print(products.value);
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
      ),
      body: Obx(() => ListView.builder(
            itemCount: products.length,
            itemBuilder: (BuildContext context, int index) {
              Product product = products[index];
              return Padding(
                padding: const EdgeInsets.all(3.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade400,
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: ListTile(
                    leading: SizedBox(
                      width: 60,
                      height: 60,
                      child: product.image != null
                          ? Image.file(
                              File(product.image.toString()),
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: Colors.grey,
                            ),
                    ),
                    title: Text(product.name),
                    subtitle: Text(product.description),
                    onTap: () async {
                      print(product.toJson());
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        Get.to(EditProductPage(
                          product: product,
                          reload: getProductsDB,
                        ));
                      },
                    ),
                  ),
                ),
              );
            },
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(
            CreateProductPage(reload: getProductsDB),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
