import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_tablet/ui/shifts/shift_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_core/util/result.dart';

class StartShiftScreen extends StatefulWidget {
  const StartShiftScreen({super.key});

  @override
  State<StartShiftScreen> createState() => _StartShiftScreenState();
}

class _StartShiftScreenState extends State<StartShiftScreen> {
  final _formKey = GlobalKey<FormState>();
  final _openingCashController = TextEditingController();

  late ShiftViewModel _shiftViewModel;

  @override
  void initState() {
    super.initState();
    _shiftViewModel = context.read<ShiftViewModel>();
    _shiftViewModel.startShift.addListener(_onStartShiftResult);
  }

  @override
  void dispose() {
    _shiftViewModel.startShift.removeListener(_onStartShiftResult);
    _openingCashController.dispose();
    super.dispose();
  }

  void _onStartShiftResult() {
    final command = _shiftViewModel.startShift;

    if (command.error) {
      final result = command.result;
      var message = 'Could not start shift.';

      if (result is Error) {
        message = result.toString().replaceAll('Exception: ', '');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );

      command.clearResult();
      return;
    }

    if (command.completed) {
      command.clearResult();
      if (mounted) context.goNamed('dashboard');
    }
  }

  void _startShift() {
    if (!_formKey.currentState!.validate()) return;

    final dollars = double.parse(_openingCashController.text.trim());
    final cents = (dollars * 100).round(); // safe: validator limits to 2 dp

    _shiftViewModel.startShift.execute(cents);
  }

  @override
  Widget build(BuildContext context) {
    final isStarting = context.watch<ShiftViewModel>().startShift.running;

    return Scaffold(
      appBar: AppBar(title: const Text('Start Shift')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Opening Cash Float',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text('Count the cash in the drawer before you begin.'),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _openingCashController,
                    enabled: !isStarting,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Opening cash (USD)',
                      prefixText: '\$ ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final amount = double.tryParse(value?.trim() ?? '');

                      if (amount == null || !amount.isFinite || amount < 0) {
                        return 'Enter a valid amount of \$0 or more.';
                      }

                      if ((amount * 100 - (amount * 100).round()).abs() >
                          0.000001) {
                        return 'Enter no more than 2 decimal places.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: isStarting ? null : _startShift,
                    child: isStarting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Start Shift'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
