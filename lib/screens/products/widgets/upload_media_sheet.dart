import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:bdcomputing/core/styles.dart';
import 'package:bdcomputing/screens/products/products_provider.dart';

class UploadMediaSheet extends ConsumerStatefulWidget {
  final String productId;
  final String mediaType; // 'product-image' or 'product-specification'
  final String title;
  final List<String>? allowedExtensions;

  const UploadMediaSheet({
    super.key,
    required this.productId,
    required this.mediaType,
    required this.title,
    this.allowedExtensions,
  });

  @override
  ConsumerState<UploadMediaSheet> createState() => _UploadMediaSheetState();
}

class _UploadMediaSheetState extends ConsumerState<UploadMediaSheet> {
  final List<File> _selectedFiles = [];
  bool _isUploading = false;

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: widget.allowedExtensions != null ? FileType.custom : FileType.image,
        allowedExtensions: widget.allowedExtensions,
      );

      if (result != null) {
        setState(() {
          _selectedFiles.addAll(result.paths.map((path) => File(path!)));
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking files: $e')),
      );
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  Future<void> _upload() async {
    if (_selectedFiles.isEmpty) return;

    setState(() => _isUploading = true);

    try {
      final notifier = ref.read(productsProvider.notifier);
      final paths = _selectedFiles.map((file) => file.path).toList();
      
      final success = await notifier.uploadProductMedia(
        productId: widget.productId,
        filePaths: paths,
        type: widget.mediaType,
      );

      if (!mounted) return;

      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Upload successful'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh product details
        ref.invalidate(productDetailsProvider(widget.productId));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Upload failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_selectedFiles.isEmpty)
            GestureDetector(
              onTap: _pickFiles,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const HugeIcon(
                      icon: HugeIcons.strokeRoundedCloudUpload,
                      color: AppColors.primary,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tap to select files',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _selectedFiles.length + 1,
                itemBuilder: (context, index) {
                  if (index == _selectedFiles.length) {
                    return TextButton.icon(
                      onPressed: _pickFiles,
                      icon: const Icon(Icons.add),
                      label: const Text('Add more files'),
                    );
                  }
                  final file = _selectedFiles[index];
                  return ListTile(
                    leading: const Icon(Icons.file_present),
                    title: Text(
                      file.path.split('/').last,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => _removeFile(index),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isUploading || _selectedFiles.isEmpty ? null : _upload,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isUploading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Upload',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}
