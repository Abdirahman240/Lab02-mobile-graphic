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
  ShoppingItem? selectedItem;

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

  Future<void> deleteSelectedItem() async {
    final item = selectedItem;

    if (item == null) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Delete Item"),
          content: Text("Delete ${item.name}?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    if (item.id != null) {
      await _dao.deleteItem(item.id!);
    }

    if (!mounted) return;

    setState(() {
      selectedItem = null;
    });

    await loadItems();
  }

  Widget buildItemList() {
    return Padding(
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
                  selected: selectedItem?.id == item.id,
                  onTap: () {
                    setState(() {
                      selectedItem = item;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDetailsPage() {
    final item = selectedItem;

    if (item == null) {
      return const Center(
        child: Text(
          "Select an item to view its details",
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Item Details",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 30),
          Text(
            "Name: ${item.name}",
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 15),
          Text(
            "Quantity: ${item.quantity}",
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 15),
          Text(
            "Database ID: ${item.id}",
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: deleteSelectedItem,
            child: const Text("Delete"),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              setState(() {
                selectedItem = null;
              });
            },
            child: const Text("Close"),
          ),
        ],
      ),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTabletOrDesktop = constraints.maxWidth >= 600;

          if (isTabletOrDesktop) {
            return Row(
              children: [
                Expanded(
                  flex: 1,
                  child: buildItemList(),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  flex: 1,
                  child: buildDetailsPage(),
                ),
              ],
            );
          }

          if (selectedItem != null) {
            return buildDetailsPage();
          }

          return buildItemList();
        },
      ),
    );
  }
}