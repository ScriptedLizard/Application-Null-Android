import 'package:flutter/material.dart';

class WheelPickerDialog extends StatefulWidget {
  const WheelPickerDialog({super.key});

  @override
  State<WheelPickerDialog> createState() => _WheelPickerDialogState();
}

class _WheelPickerDialogState extends State<WheelPickerDialog> {
  int _num = 1;
  String _letter1 = 'A';
  String _letter2 = 'M';

  final List<String> _wheel1 = List.generate(9, (i) => '${i + 1}');
  final List<String> _wheel2 = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N'];
  final List<String> _wheel3 = ['M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Select your thingy',
        style: TextStyle(color: colorScheme.onSurface),
      ),
      content: SizedBox(
        height: 200,
        child: Row(
          children: [
            Expanded(child: _buildWheel(_wheel1, (v) => setState(() => _num = int.parse(v)))),
            _buildDivider(),
            Expanded(child: _buildWheel(_wheel2, (v) => setState(() => _letter1 = v))),
            _buildDivider(),
            Expanded(child: _buildWheel(_wheel3, (v) => setState(() => _letter2 = v))),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, '$_num · $_letter1 · $_letter2'),
          child: const Text('Select'),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(vertical: 20),
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.15),
    );
  }

  Widget _buildWheel(List<String> items, ValueChanged<String> onChanged) {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        ListWheelScrollView.useDelegate(
          itemExtent: 44,
          perspective: 0.003,
          diameterRatio: 1.4,
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: (i) => onChanged(items[i]),
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: items.length,
            builder: (context, i) => Center(
              child: Text(
                items[i],
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
