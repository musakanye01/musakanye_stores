import 'package:flutter/material.dart';
import 'package:pos_tablet/ui/bootstrap/bootstrap_view_model.dart';
import 'package:provider/provider.dart';

class BootstrapScreen extends StatelessWidget {
  const BootstrapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BootstrapViewModel>(
      builder: (context, model, _) {
        return Scaffold(
          body: Center(
            child: switch (model.status) {
              BootstrapStatus.bootstrapping =>
                const CircularProgressIndicator(),

              BootstrapStatus.error => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(model.errorMessage ?? 'Bootstrap failed'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: model.bootstrap,
                    child: const Text('Retry'),
                  ),
                ],
              ),

              _ => ElevatedButton(
                onPressed: model.bootstrap,
                child: const Text('Initialize Device'),
              ),
            },
          ),
        );
      },
    );
  }
}
