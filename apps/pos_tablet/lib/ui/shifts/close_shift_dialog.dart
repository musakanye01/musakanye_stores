import 'package:flutter/material.dart';
import 'package:pos_tablet/ui/shared/money.dart';

typedef CloseShiftDetails = ({int countedCashCents, String? note});

class CloseShiftDialog extends StatefulWidget {
  const CloseShiftDialog({super.key});

  static Future<CloseShiftDetails?> show(BuildContext context) {
    return showDialog<CloseShiftDetails>(
      context: context,
      builder: (_) => const CloseShiftDialog(),
    );
  }

  @override
  State<CloseShiftDialog> createState() => _CloseShiftDialogState();
}

class _CloseShiftDialogState extends State<CloseShiftDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cashController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _cashController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final note = _noteController.text.trim();
    Navigator.pop<CloseShiftDetails>(context, (
      countedCashCents: parseUsdToCents(_cashController.text)!,
      note: note.isEmpty ? null : note,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Close shift?'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Count the physical cash in the till. '
                'Do not include EcoCash or bank transfers.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cashController,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Physical cash counted (USD)',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => parseUsdToCents(value ?? '') == null
                    ? 'Enter a valid amount with up to 2 decimals.'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Closing note (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Confirm Close')),
      ],
    );
  }
}
