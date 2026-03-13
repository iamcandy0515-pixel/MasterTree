import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_admin_app/features/tree_registration/viewmodels/tree_registration_viewmodel.dart';
import 'package:flutter_admin_app/features/trees/models/tree.dart';

class SmartTagImageSection extends StatelessWidget {
  const SmartTagImageSection({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TreeRegistrationViewModel>();
    
    final tags = {
      'main': '대표',
      'leaf': '잎',
      'bark': '수피',
      'flower': '꽃',
      'fruit': '열매',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('2. 부위별 이미지 및 힌트', style: TextStyle(color: Color(0xFF80F20D), fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        
        // Tag Selection (Chips)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: tags.entries.map((e) {
              final isSelected = vm.activeTag == e.key;
              final hasImage = vm.taggedImages.containsKey(e.key);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(e.value),
                  selected: isSelected,
                  onSelected: (selected) => vm.setActiveTag(e.key),
                  selectedColor: const Color(0xFF80F20D),
                  backgroundColor: const Color(0xFF161B12),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : (hasImage ? Colors.white : Colors.white38),
                    fontWeight: FontWeight.bold,
                  ),
                  avatar: hasImage ? const Icon(Icons.check_circle, size: 16, color: Colors.green) : null,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),

        // Image & Hint Area for Active Tag
        _buildActiveTagEditor(context, vm),
      ],
    );
  }

  Widget _buildActiveTagEditor(BuildContext context, TreeRegistrationViewModel vm) {
    final image = vm.taggedImages[vm.activeTag];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          // Image Area
          if (image == null)
            _buildUploadBox(context, vm)
          else
            _buildImageItem(vm, image),
          
          const SizedBox(height: 20),
          
          // Hint Area
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('이 부위의 퀴즈 힌트', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
              const SizedBox(height: 8),
              TextField(
                onChanged: (v) => vm.updateHint(vm.activeTag, v),
                controller: TextEditingController(text: image?.hint)..selection = TextSelection.collapsed(offset: (image?.hint ?? '').length),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: '문제가 나왔을 때 사용자에게 보여줄 힌트를 입력하세요.',
                  hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUploadBox(BuildContext context, TreeRegistrationViewModel vm) {
    return GestureDetector(
      onTap: () async {
        final picker = ImagePicker();
        final file = await picker.pickImage(source: ImageSource.gallery);
        if (file != null) vm.handleImageUpload(file);
      },
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (vm.isUploading)
              const CircularProgressIndicator(color: Color(0xFF80F20D))
            else ...[
              const Icon(Icons.add_a_photo_outlined, color: Colors.white38, size: 32),
              const SizedBox(height: 8),
              const Text('클릭하여 이미지 업로드', style: TextStyle(color: Colors.white38, fontSize: 12)),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildImageItem(TreeRegistrationViewModel vm, TreeImage image) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            image.imageUrl,
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, color: Colors.white10)),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
            onPressed: () => vm.removeImage(vm.activeTag),
            style: IconButton.styleFrom(backgroundColor: Colors.black54),
          ),
        ),
      ],
    );
  }
}
