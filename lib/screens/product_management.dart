import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProductManagement extends StatefulWidget {
  final String productType;

  const ProductManagement({super.key, required this.productType});

  @override
  State<ProductManagement> createState() => _ProductManagementState();
}

class _ProductManagementState extends State<ProductManagement> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isUploading = false;
  double _thickness = 1.0;
  bool _hairStrokes = true;

  // Database paths
  String get _productsPath => '${widget.productType}_products';

  // Shape images
  final Map<String, String> _eyebrowShapeImages = {
    'natural': 'assets/eyebrows/natural_right.png',
    'straight': 'assets/eyebrows/straight_right.png',
    'soft angled': 'assets/eyebrows/soft_angled_right.png',
    'high arch': 'assets/eyebrows/high_arch_right.png',
    'thick': 'assets/eyebrows/thick_right.png',
  };

  final Map<String, String> _nailpaintShapeImages = {
    'shape': 'assets/nails/nail_round.png',
    'almond': 'assets/nails/nail_almond.png',
  };

  final Map<String, List<Map<String, dynamic>>> _hardcodedProducts = {
    'lipstick': [
      {
        'name': 'Classic Red',
        'color': '#D10000',
        'opacity': 0.8,
        'isHardcoded': true,
      },
      {
        'name': 'Hot Pink',
        'color': '#FF69B4',
        'opacity': 0.9,
        'isHardcoded': true,
      },
      {
        'name': 'Nude',
        'color': '#E3C9B5',
        'opacity': 0.7,
        'isHardcoded': true,
      },
      {
        'name': 'Berry',
        'color': '#991C42',
        'opacity': 0.85,
        'isHardcoded': true,
      },
      {
        'name': 'Coral',
        'color': '#FF7F50',
        'opacity': 0.8,
        'isHardcoded': true,
      },
      {
        'name': 'Mauve',
        'color': '#915F6D',
        'opacity': 0.75,
        'isHardcoded': true,
      },
      {
        'name': 'Burgundy',
        'color': '#800020',
        'opacity': 0.9,
        'isHardcoded': true,
      },
      {
        'name': 'Peach Nude',
        'color': '#FFDAB9',
        'opacity': 0.6,
        'isHardcoded': true,
      },
    ],
    'foundation': [
      {
        'name': 'Porcelain',
        'shade': '#F5D0B9',
        'opacity': 0.95,
        'isHardcoded': true,
      },
      {
        'name': 'Ivory',
        'shade': '#EEC1A2',
        'opacity': 0.95,
        'isHardcoded': true,
      },
      {
        'name': 'Beige',
        'shade': '#E0AC8B',
        'opacity': 0.95,
        'isHardcoded': true,
      },
      {
        'name': 'Sand',
        'shade': '#D19C7C',
        'opacity': 0.95,
        'isHardcoded': true,
      },
      {
        'name': 'Honey',
        'shade': '#B07D62',
        'opacity': 0.95,
        'isHardcoded': true,
      },
      {
        'name': 'Caramel',
        'shade': '#8C5D45',
        'opacity': 0.95,
        'isHardcoded': true,
      },
      {
        'name': 'Espresso',
        'shade': '#5D4037',
        'opacity': 0.95,
        'isHardcoded': true,
      },
      {
        'name': 'Mocha',
        'shade': '#3E2723',
        'opacity': 0.95,
        'isHardcoded': true,
      },
    ],
    'nailpaint': [
      {
        'name': 'Classic Red',
        'color': '#FF0000',
        'opacity': 0.9,
        'isHardcoded': true,
      },
      {
        'name': 'Bubblegum Pink',
        'color': '#FF69B4',
        'opacity': 0.9,
        'shape': 'almond',
        'magnitude': 1.0,
        'isHardcoded': true,
      },
      {
        'name': 'Round Shape',
        'shape': 'shape',
        'isHardcoded': true,
        'isShape': true,
      },
      {
        'name': 'Almond Shape',
        'shape': 'almond',
        'isHardcoded': true,
        'isShape': true,
      },
    ],
    'eyebrow': [
      {
        'name': 'Natural',
        'shape': 'natural',
        'isHardcoded': true,
        'isShape': true,
      },
      {
        'name': 'Straight',
        'shape': 'straight',
        'isHardcoded': true,
        'isShape': true,
      },
      {
        'name': 'Soft Angled',
        'shape': 'soft angled',
        'isHardcoded': true,
        'isShape': true,
      },
      {
        'name': 'High Arch',
        'shape': 'high arch',
        'isHardcoded': true,
        'isShape': true,
      },
      {
        'name': 'Thick',
        'shape': 'thick',
        'isHardcoded': true,
        'isShape': true,
      },
    ],
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage ${widget.productType} Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddProductDialog,
          ),
        ],
      ),
      body: _isUploading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildStatsSection(),
                Expanded(
                  child: _buildProductsList(),
                ),
              ],
            ),
    );
  }

  Widget _buildProductsList() {
    return StreamBuilder<DatabaseEvent>(
      stream: _databaseRef.child(_productsPath).onValue,
      builder: (context, snapshot) {
        List<Map<String, dynamic>> allProducts = [
          ..._hardcodedProducts[widget.productType] ?? [],
        ];

        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          final dynamicData =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          dynamicData.forEach((key, value) {
            allProducts.add({
              ...value as Map<dynamic, dynamic>,
              'id': key,
              'isHardcoded': false,
            });
          });
        }

        if (allProducts.isEmpty) {
          return Center(
            child: Text('No ${widget.productType} products found'),
          );
        }

        return ListView.builder(
          itemCount: allProducts.length,
          itemBuilder: (context, index) {
            final product = allProducts[index];
            return _buildProductCard(
              product,
              isHardcoded: product['isHardcoded'] ?? false,
              productKey: product['id']?.toString() ?? index.toString(),
            );
          },
        );
      },
    );
  }

  Widget _buildStatsSection() {
    return StreamBuilder<DatabaseEvent>(
      stream: _databaseRef.child(_productsPath).onValue,
      builder: (context, snapshot) {
        int hardcodedCount =
            _hardcodedProducts[widget.productType]?.length ?? 0;
        int dynamicCount = 0;

        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          dynamicCount =
              (snapshot.data!.snapshot.value as Map<dynamic, dynamic>).length;
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('Hardcoded', '$hardcodedCount', Icons.lock),
              _buildStatItem('Dynamic', '$dynamicCount', Icons.cloud),
              _buildStatItem('Total', '${hardcodedCount + dynamicCount}',
                  Icons.shopping_bag),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildProductCard(
    Map<String, dynamic> product, {
    required bool isHardcoded,
    required String productKey,
  }) {
    final isShape = product['isShape'] ?? false;
    final colorHex = product['color'] ?? product['shade'] ?? '#FFFFFF';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: _buildProductLeading(product),
        title: Text(product['name']?.toString() ?? 'Unnamed Product'),
        subtitle: !isShape
            ? Text(colorHex, style: const TextStyle(fontSize: 12))
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isHardcoded)
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () => _showEditProductDialog(productKey, product),
              ),
            if (!isHardcoded)
              IconButton(
                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                onPressed: () =>
                    _deleteProduct(productKey, product['imageUrl']),
              ),
            if (isHardcoded)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Default', style: TextStyle(color: Colors.grey)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductLeading(Map<String, dynamic> product) {
    // Show uploaded image if available
    if (product['imageUrl'] != null) {
      return Image.network(product['imageUrl'].toString(),
          width: 50, height: 50, fit: BoxFit.cover);
    }

    // Show shape image for eyebrow and nailpaint shapes
    if (product['isShape'] == true) {
      final shape = product['shape']?.toString().toLowerCase() ?? '';

      if (widget.productType == 'eyebrow' &&
          _eyebrowShapeImages.containsKey(shape)) {
        return Image.asset(_eyebrowShapeImages[shape]!,
            width: 50, height: 50, fit: BoxFit.contain);
      }

      if (widget.productType == 'nailpaint' &&
          _nailpaintShapeImages.containsKey(shape)) {
        return Image.asset(_nailpaintShapeImages[shape]!,
            width: 50, height: 50, fit: BoxFit.contain);
      }
    }

    // Default color swatch for regular products
    final colorHex = product['color'] ?? product['shade'] ?? '#FFFFFF';
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Color(int.parse(colorHex.substring(1), radix: 16) + 0xFF000000),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey),
      ),
    );
  }

  void _showAddProductDialog() {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    String _colorHex = '#FF0000';
    double _opacity = 0.7;
    String _shape = 'shape'; // Default shape for nailpaint
    double _magnitude =
        1.0; // Renamed from _length to match your hardcoded data
    bool _showOutline = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add ${widget.productType} Product'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Image Picker
                      GestureDetector(
                        onTap: () async {
                          await _pickImage();
                          setState(() {});
                        },
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _imageFile != null
                              ? Image.file(_imageFile!, fit: BoxFit.cover)
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.add_a_photo, size: 40),
                                    SizedBox(height: 8),
                                    Text('Add Product Image'),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Name Field
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),

                      // Color Field for lipstick and nailpaint
                      if (widget.productType == 'lipstick' ||
                          widget.productType == 'nailpaint')
                        _buildColorField(_colorHex, (value) {
                          setState(() => _colorHex = value);
                        }),

                      // Shade Field for foundation
                      if (widget.productType == 'foundation')
                        _buildColorField(_colorHex, (value) {
                          setState(() => _colorHex = value);
                        }),

                      // Shape selector for eyebrow and nailpaint
                      if (widget.productType == 'eyebrow' ||
                          widget.productType == 'nailpaint')
                        _buildShapeSelector(_shape, (value) {
                          setState(() => _shape = value);
                        }),

                      // Nailpaint specific fields
                      if (widget.productType == 'nailpaint')
                        Column(
                          children: [
                            _buildSlider(
                              'Magnitude',
                              _magnitude,
                              0.5,
                              2.0,
                              (value) => setState(() => _magnitude = value),
                            ),
                            SwitchListTile(
                              title: const Text('Show Outline'),
                              value: _showOutline,
                              onChanged: (value) =>
                                  setState(() => _showOutline = value),
                            ),
                          ],
                        ),

                      // Eyebrow specific fields
                      if (widget.productType == 'eyebrow')
                        Column(
                          children: [
                            _buildSlider(
                              'Thickness',
                              _thickness,
                              0.5,
                              2.0,
                              (value) => setState(() => _thickness = value),
                            ),
                            SwitchListTile(
                              title: const Text('Hair Strokes'),
                              value: _hairStrokes,
                              onChanged: (value) =>
                                  setState(() => _hairStrokes = value),
                            ),
                          ],
                        ),

                      // Opacity for all products
                      _buildSlider('Opacity', _opacity, 0.1, 1.0, (value) {
                        setState(() => _opacity = value);
                      }),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() => _isUploading = true);
                      Navigator.pop(context);

                      try {
                        final imageUrl = await _uploadImage();

                        Map<String, dynamic> productData = {
                          'name': _nameController.text,
                          'opacity': _opacity,
                          'createdAt': ServerValue.timestamp,
                        };

                        // Add image URL if available
                        if (imageUrl.isNotEmpty) {
                          productData['imageUrl'] = imageUrl;
                        }

                        // Add product-specific fields
                        if (widget.productType == 'lipstick' ||
                            widget.productType == 'nailpaint') {
                          productData['color'] = _colorHex;
                        }

                        if (widget.productType == 'foundation') {
                          productData['shade'] = _colorHex;
                        }

                        if (widget.productType == 'eyebrow') {
                          productData.addAll({
                            'shape': _shape,
                            'thickness': _thickness,
                            'hair_strokes': _hairStrokes,
                          });
                        }

                        if (widget.productType == 'nailpaint') {
                          productData.addAll({
                            'shape': _shape,
                            'magnitude':
                                _magnitude, // Using magnitude instead of length
                            'show_outline': _showOutline,
                          });
                        }

                        await _databaseRef
                            .child(_productsPath)
                            .push()
                            .set(productData);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Product added successfully')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      } finally {
                        setState(() {
                          _imageFile = null;
                          _isUploading = false;
                        });
                      }
                    }
                  },
                  child: const Text('Add Product'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditProductDialog(
      String productKey, Map<dynamic, dynamic> product) {
    final _formKey = GlobalKey<FormState>();
    final _nameController =
        TextEditingController(text: product['name']?.toString() ?? '');

    String _colorHex = product['color']?.toString() ??
        product['shade']?.toString() ??
        '#FF0000';
    double _opacity = product['opacity']?.toDouble() ?? 0.7;
    String _shape = product['shape']?.toString() ?? 'natural';
    double _thickness = product['thickness']?.toDouble() ?? 1.0;
    bool _hairStrokes = product['hair_strokes'] ?? true;
    double _length = product['length']?.toDouble() ?? 1.0;
    bool _showOutline = product['show_outline'] ?? true;
    String? _currentImageUrl = product['imageUrl']?.toString();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit ${product['name']}'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await _pickImage();
                          setState(() {});
                        },
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _imageFile != null
                              ? Image.file(_imageFile!, fit: BoxFit.cover)
                              : _currentImageUrl != null
                                  ? Image.network(_currentImageUrl,
                                      fit: BoxFit.cover)
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.add_a_photo, size: 40),
                                        SizedBox(height: 8),
                                        Text('Add Product Image'),
                                      ],
                                    ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          prefixText: '\$ ',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null,
                      ),

                      // Product-specific fields
                      if (widget.productType == 'lipstick' ||
                          widget.productType == 'nailpaint')
                        _buildColorField(_colorHex, (value) {
                          setState(() => _colorHex = value);
                        }),

                      if (widget.productType == 'foundation')
                        _buildColorField(_colorHex, (value) {
                          setState(() => _colorHex = value);
                        }),

                      if (widget.productType == 'eyebrow' ||
                          widget.productType == 'nailpaint')
                        _buildShapeSelector(_shape, (value) {
                          setState(() => _shape = value);
                        }),

                      if (widget.productType == 'eyebrow')
                        _buildSlider('Thickness', _thickness, 0.5, 2.0,
                            (value) {
                          setState(() => _thickness = value);
                        }),

                      if (widget.productType == 'eyebrow')
                        SwitchListTile(
                          title: const Text('Hair Strokes'),
                          value: _hairStrokes,
                          onChanged: (value) =>
                              setState(() => _hairStrokes = value),
                        ),

                      if (widget.productType == 'nailpaint')
                        _buildSlider('Length', _length, 0.5, 2.0, (value) {
                          setState(() => _length = value);
                        }),

                      if (widget.productType == 'nailpaint')
                        SwitchListTile(
                          title: const Text('Show Outline'),
                          value: _showOutline,
                          onChanged: (value) =>
                              setState(() => _showOutline = value),
                        ),

                      // Opacity for all products
                      _buildSlider('Opacity', _opacity, 0.1, 1.0, (value) {
                        setState(() => _opacity = value);
                      }),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() => _isUploading = true);
                      Navigator.pop(context);

                      try {
                        String? imageUrl = _currentImageUrl;
                        if (_imageFile != null) {
                          // Delete old image if we're replacing it
                          if (_currentImageUrl != null) {
                            await _storage
                                .refFromURL(_currentImageUrl)
                                .delete();
                          }
                          imageUrl = await _uploadImage();
                        }

                        Map<String, dynamic> updateData = {
                          'name': _nameController.text,
                          'opacity': _opacity,
                          'imageUrl': imageUrl,
                          'updatedAt': ServerValue.timestamp,
                        };

                        // Add product-specific fields
                        if (widget.productType == 'lipstick' ||
                            widget.productType == 'nailpaint') {
                          updateData['color'] = _colorHex;
                        }
                        if (widget.productType == 'foundation') {
                          updateData['shade'] = _colorHex;
                        }
                        if (widget.productType == 'eyebrow') {
                          updateData.addAll({
                            'shape': _shape,
                            'thickness': _thickness,
                            'hair_strokes': _hairStrokes,
                          });
                        }
                        if (widget.productType == 'nailpaint') {
                          updateData.addAll({
                            'shape': _shape,
                            'length': _length,
                            'show_outline': _showOutline,
                          });
                        }

                        await _databaseRef
                            .child('${widget.productType}_products')
                            .child(productKey)
                            .update(updateData);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Product updated successfully')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      } finally {
                        setState(() {
                          _imageFile = null;
                          _isUploading = false;
                        });
                      }
                    }
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildColorField(String currentValue, ValueChanged<String> onChanged) {
    return TextFormField(
      initialValue: currentValue.startsWith('#')
          ? currentValue.substring(1)
          : currentValue,
      decoration: const InputDecoration(
        labelText: 'Hex Color',
        border: OutlineInputBorder(),
        prefixText: '#',
        hintText: 'FF0000',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        if (!RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(value)) {
          return 'Invalid hex code (e.g., FF0000)';
        }
        return null;
      },
      onChanged: (value) => onChanged('#${value.replaceAll('#', '')}'),
    );
  }

  Widget _buildShapeSelector(
      String currentValue, ValueChanged<String> onChanged) {
    List<String> shapes = [];
    if (widget.productType == 'eyebrow') {
      shapes = ['natural', 'straight', 'soft angled', 'high arch', 'thick'];
    } else if (widget.productType == 'nailpaint') {
      shapes = ['shape', 'almond']; // Match the keys in _nailpaintShapeImages
    }

    return DropdownButtonFormField<String>(
      value: currentValue,
      decoration: const InputDecoration(
        labelText: 'Shape',
        border: OutlineInputBorder(),
      ),
      items: shapes.map((shape) {
        return DropdownMenuItem(
          value: shape,
          child: Text(shape[0].toUpperCase() + shape.substring(1)),
        );
      }).toList(),
      onChanged: (value) => onChanged(value!),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max,
      ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ${value.toStringAsFixed(1)}'),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: 10,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<String> _uploadImage() async {
    if (_imageFile == null) return '';

    try {
      setState(() => _isUploading = true);
      final ref = _storage
          .ref()
          .child('${widget.productType}_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = ref.putFile(_imageFile!);
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
      rethrow;
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _deleteProduct(String productKey, String? imageUrl) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isUploading = true);
      try {
        // Delete the image first
        if (imageUrl != null && imageUrl.isNotEmpty) {
          await _storage.refFromURL(imageUrl).delete();
        }
        // Then delete the product
        await _databaseRef
            .child('${widget.productType}_products')
            .child(productKey)
            .remove();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting product: $e')),
        );
      } finally {
        setState(() => _isUploading = false);
      }
    }
  }
}
