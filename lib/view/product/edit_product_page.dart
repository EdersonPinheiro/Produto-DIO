import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/product/product_controller.dart';
import '../../db/db.dart';
import '../../model/product.dart';
import 'package:image_picker/image_picker.dart';

class EditProductPage extends StatefulWidget {
  final Product product;
  final Function reload;

  EditProductPage({required this.product, required this.reload});

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final db = DB();
  ProductController controller = ProductController();

  @override
  void initState() {
    super.initState();
    controller.imageController.text = widget.product.image;
    controller.localIdController.text = widget.product.localId!;
    controller.nameController.text = widget.product.name;
    controller.descriptionController.text = widget.product.description;
  }

  final ImagePicker _picker = ImagePicker();
  XFile? imageFile;

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final File file = File(image.path);
      imageFile = image;
      setState(() {
        controller.imageController.text = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.product.name), actions: [
        IconButton(onPressed: () async {}, icon: Icon(Icons.image))
      ]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Form(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  SizedBox(height: 30),
                  controller.imageController.text.isNotEmpty
                      ? Column(
                          children: [
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: Image.file(
                                File(controller.imageController.text),
                                fit: BoxFit.cover,
                              ),
                            ),
                            Align(
                              alignment: Alignment(0.5, 0.5),
                              child: IconButton(
                                iconSize: 45,
                                icon: Icon(Icons.image_outlined),
                                onPressed: pickImage,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              color: Colors.grey,
                            ),
                            Align(
                              alignment: Alignment(0.5, 0.5),
                              child: IconButton(
                                iconSize: 45,
                                icon: Icon(Icons.image_outlined),
                                onPressed: pickImage,
                              ),
                            ),
                          ],
                        ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: controller.nameController,
                    decoration: const InputDecoration(labelText: 'Nome'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Por favor, insira o nome do produto';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: controller.descriptionController,
                    decoration: const InputDecoration(labelText: 'Descrição'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final newProduct = Product(
                                localId: widget.product.localId,
                                image: controller.imageController.text,
                                name: controller.nameController.text,
                                description:
                                    controller.descriptionController.text,
                                quantity: widget.product.quantity,
                                status: "edit");
                            await db.updateProduct(newProduct);
                            Get.back();
                            widget.reload();
                          },
                          child: const Text('Salvar'),
                        ),
                      ),
                      const SizedBox(
                        width: 32,
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final newProduct = Product(
                                localId: widget.product.localId,
                                image: widget.product.image,
                                name: widget.product.name,
                                description: widget.product.description,
                                quantity: widget.product.quantity,
                                status: "delete");
                            await db.deleteProductDB(newProduct);
                            Get.back();
                            widget.reload();
                          },
                          child: const Text('Excluir'),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                              return Colors.red;
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tem certeza que deseja excluir este produto ?'),
          content: Text(
              'Excluindo o produto você também exclui todo o histórico de movimentações relacionado'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                //await db.deleteProductDB(widget.product);
              },
              child: const Text(
                'Excluir',
                style: TextStyle(color: Colors.white),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  return Colors.red;
                }),
              ),
            ),
          ],
        );
      },
    );
  }
}
