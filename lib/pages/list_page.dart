import 'package:flutter/material.dart';

import '../database/shopping_item_dao.dart';
import '../models/shopping_item.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  final ShoppingItemDao _dao = ShoppingItemDao.instance;

  List<ShoppingItem> shoppingList = [];

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    final items = await _dao.getAllItems();

    if (!mounted) return;

    setState(() {
      shoppingList = items;
    });
  }

  Future<void> addItem() async {
    final name = _itemController.text.trim();
    final quantity = int.tryParse(_quantityController.text.trim());

    if (name.isEmpty || quantity == null || quantity <= 0) {
      return;
    }

    final newItem = ShoppingItem(
      name: name,
      quantity: quantity,
    );

    await _dao.insertItem(newItem);

    _itemController.clear();
    _quantityController.clear();

    await loadItems();
  }

  void deleteItem(int index) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Delete Item"),
          content: const Text("Do you want to delete this item?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () async {
                final item = shoppingList[index];

                if (item.id != null) {
                  await _dao.deleteItem(item.id!);
                }

                if (!mounted) return;

                Navigator.pop(dialogContext);
                await loadItems();
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _itemController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shopping List"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _itemController,
              decoration: const InputDecoration(
                labelText: "Item Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Quantity",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: addItem,
              child: const Text("Add"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: shoppingList.isEmpty
                  ? const Center(
                child: Text("There are no items in the list"),
              )
                  : ListView.builder(
                itemCount: shoppingList.length,
                itemBuilder: (context, index) {
                  final item = shoppingList[index];

                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text(
                      "Quantity: ${item.quantity}",
                    ),
                    onLongPress: () {
                      deleteItem(index);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}