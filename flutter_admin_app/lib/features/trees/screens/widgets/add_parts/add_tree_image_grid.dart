import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/add_tree_viewmodel.dart';

class AddTreeImageGrid extends StatelessWidget {
  final Map<String, String> labels;
  const AddTreeImageGrid({super.key, required this.labels});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddTreeViewModel>();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: vm.uploadedImages.length,
      itemBuilder: (context, index) {
        final img = vm.uploadedImages[index];
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(img.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            _RemoveButton(index: index, vm: vm),
            _TypeLabel(label: labels[img.imageType] ?? img.imageType),
          ],
        );
      },
    );
  }
}

class _RemoveButton extends StatelessWidget {
  final int index;
  final AddTreeViewModel vm;
  const _RemoveButton({required this.index, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 4,
      right: 4,
      child: GestureDetector(
        onTap: () => vm.removeImage(index),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
          child: const Icon(Icons.close, size: 14, color: Colors.white),
        ),
      ),
    );
  }
}

class _TypeLabel extends StatelessWidget {
  final String label;
  const _TypeLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        color: Colors.black54,
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 10),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
