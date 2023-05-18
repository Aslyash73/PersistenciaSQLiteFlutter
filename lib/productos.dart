import 'package:flutter/material.dart';
import 'package:tallersqlite/db_helper.dart';

class Productos extends StatefulWidget {
  const Productos({Key? key}) : super(key: key);

  @override
  State<Productos> createState() => _ProductosState();
}

class _ProductosState extends State<Productos> {
  List<Map<String, dynamic>> _allData = [];
  List<bool> _selectedItems = [];
  bool _isLoading = true;

  void _refreshData() async {
    final data = await SQLHelper.getAllData();
    setState(() {
      _allData = data;
      _selectedItems = List<bool>.filled(data.length, false);
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _addData() async {
    await SQLHelper.createData(
        _productosController.text, _precioController.text);
    _refreshData();
  }

  Future<void> _updateData(int id) async {
    await SQLHelper.updateData(
        id, _productosController.text, _precioController.text);
    _refreshData();
  }

  Future<void> _deleteData(int id) async {
    await SQLHelper.deleteData(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.redAccent,
      content: Text("User Deleted"),
    ));
    _refreshData();
  }

  final TextEditingController _productosController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();

  void showBottomSheet(int? id) async {
    if (id != null) {
      final existingData =
          _allData.firstWhere((element) => element['id'] == id);
      _productosController.text = existingData['title'];
      _precioController.text = existingData['desc'];
    }
    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: context,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 30,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 50,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _productosController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Escriba que producto quiere comprar",
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _precioController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Ingrese la descripcion",
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (id == null) {
                    await _addData();
                  } else {
                    await _updateData(id);
                  }
                  _productosController.text = "";
                  _precioController.text = "";
                  // Hide bottom sheet
                  Navigator.of(context).pop();
                  print("User Added");
                },
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    id == null ? "Add Data" : "Update",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: true,
      left: true,
      right: true,
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 219, 183, 221),
        appBar: AppBar(
          toolbarHeight: 80,
          title: const Text('Productos 📝'),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _allData.isEmpty
                ? const Center(
                    child: Text(
                      'Sin registros',
                      style: TextStyle(fontSize: 24),
                    ),
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 15,
                      childAspectRatio:
                          0.75, // Relación de aspecto para ajustar el tamaño de las celdas
                    ),
                    itemCount: _allData.length,
                    itemBuilder: (context, index) {
                      final data = _allData[index];
                      return Card(
                        key: ValueKey(data['id']),
                        margin: const EdgeInsets.all(10),
                        child: InkWell(
                          onTap: () {
                            showBottomSheet(data['id']);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 2, left: 5, right: 3),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: Checkbox(
                                    value: _selectedItems[index],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedItems[index] = value ?? false;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['title'],
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        data['desc'],
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        showBottomSheet(data['id']);
                                      },
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.indigo,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        _deleteData(data['id']);
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showBottomSheet(null),
          child: const Icon(Icons.shopping_cart),
        ),
      ),
    );
  }
}
