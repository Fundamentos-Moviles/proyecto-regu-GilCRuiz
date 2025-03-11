import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

class ColorSelector extends StatefulWidget {
  final Color initialColor;
  final Function(Color) onColorChanged;

  const ColorSelector({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
  });

  @override
  State<ColorSelector> createState() => _ColorSelectorState();
}

class _ColorSelectorState extends State<ColorSelector> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seleccionar Color',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ColorPicker(
          pickersEnabled: const {
            ColorPickerType.primary: true,
            ColorPickerType.accent: true,
            ColorPickerType.wheel: true,
          },
          color: _selectedColor,
          onColorChanged: (Color color) {
            setState(() {
              _selectedColor = color;
            });
            widget.onColorChanged(color); // Llama al callback para notificar el cambio
          },
          heading: const Text('Seleccionar Color'),
          subheading: const Text('Elige una tonalidad para el fondo'),
        ),
      ],
    );
  }
}