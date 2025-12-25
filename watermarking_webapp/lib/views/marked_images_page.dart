import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:watermarking_core/watermarking_core.dart';

class MarkedImagesPage extends StatelessWidget {
  const MarkedImagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, OriginalImagesViewModel>(
      converter: (Store<AppState> store) => store.state.originals,
      builder: (BuildContext context, OriginalImagesViewModel viewModel) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Apply Watermark',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (viewModel.selectedImage != null)
                    ElevatedButton.icon(
                      onPressed: () => _showMarkDialog(context, viewModel),
                      icon: const Icon(Icons.water_drop),
                      label: const Text('Apply Watermark'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (viewModel.selectedImage == null)
                const Expanded(
                  child: Center(
                    child: Text(
                      'Select an original image first from the Original Images page.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Selected original image
                      Expanded(
                        flex: 1,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Selected Original',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: viewModel.selectedImage!.url != null
                                      ? Image.network(
                                          viewModel.selectedImage!.url!,
                                          fit: BoxFit.contain,
                                        )
                                      : const Center(
                                          child: Icon(Icons.image, size: 64),
                                        ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  viewModel.selectedImage!.name ?? 'Unnamed',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Marked images list (placeholder)
                      Expanded(
                        flex: 2,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Watermarked Versions',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Expanded(
                                  child: Center(
                                    child: Text(
                                      'Click "Apply Watermark" to create a watermarked version.',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showMarkDialog(
      BuildContext context, OriginalImagesViewModel viewModel) async {
    final messageController = TextEditingController();
    double strength = 0.5;

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Apply Watermark'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      labelText: 'Hidden Message',
                      hintText: 'Enter the message to embed',
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Strength: ${(strength * 100).toInt()}%'),
                  Slider(
                    value: strength,
                    min: 0.1,
                    max: 1.0,
                    divisions: 9,
                    onChanged: (value) {
                      setState(() {
                        strength = value;
                      });
                    },
                  ),
                  const Text(
                    'Higher strength = more visible but more robust',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (messageController.text.isNotEmpty) {
                      // TODO: Dispatch marking action
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Watermarking with message: ${messageController.text}'),
                        ),
                      );
                    }
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
