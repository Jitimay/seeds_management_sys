import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DocumentUploader extends StatefulWidget {
  final Function(File file) onFileSelected;
  final List<String> allowedExtensions;
  final String? label;
  final bool allowImages;
  final bool allowDocuments;

  const DocumentUploader({
    super.key,
    required this.onFileSelected,
    this.allowedExtensions = const ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    this.label,
    this.allowImages = true,
    this.allowDocuments = true,
  });

  @override
  State<DocumentUploader> createState() => _DocumentUploaderState();
}

class _DocumentUploaderState extends State<DocumentUploader> {
  File? _selectedFile;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
        ],
        
        if (_selectedFile != null) ...[
          _FilePreview(
            file: _selectedFile!,
            onRemove: () {
              setState(() {
                _selectedFile = null;
              });
            },
          ),
          const SizedBox(height: 16),
        ],
        
        Row(
          children: [
            if (widget.allowImages) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isUploading ? null : _pickImage,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Photo'),
                ),
              ),
              const SizedBox(width: 8),
            ],
            
            if (widget.allowDocuments) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isUploading ? null : _pickDocument,
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Document'),
                ),
              ),
            ],
          ],
        ),
        
        if (_isUploading) ...[
          const SizedBox(height: 16),
          const LinearProgressIndicator(),
        ],
      ],
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final result = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sélectionner une source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Caméra'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galerie'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    
    if (result != null) {
      final pickedFile = await picker.pickImage(source: result);
      if (pickedFile != null) {
        setState(() {
          _selectedFile = File(pickedFile.path);
        });
        widget.onFileSelected(_selectedFile!);
      }
    }
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: widget.allowedExtensions,
    );
    
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
      widget.onFileSelected(_selectedFile!);
    }
  }
}

class _FilePreview extends StatelessWidget {
  final File file;
  final VoidCallback onRemove;

  const _FilePreview({
    required this.file,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final fileName = file.path.split('/').last;
    final isImage = _isImageFile(fileName);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          if (isImage) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.file(
                file,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
          ] else ...[
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.description, size: 30),
            ),
          ],
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _formatFileSize(file.lengthSync()),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close, color: Colors.red),
          ),
        ],
      ),
    );
  }

  bool _isImageFile(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif'].contains(extension);
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class DocumentViewer extends StatelessWidget {
  final String? documentUrl;
  final String? documentPath;
  final String fileName;

  const DocumentViewer({
    super.key,
    this.documentUrl,
    this.documentPath,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fileName),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement download functionality
            },
            icon: const Icon(Icons.download),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.description, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              fileName,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text('Aperçu du document non disponible'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement external viewer
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('Ouvrir avec une autre app'),
            ),
          ],
        ),
      ),
    );
  }
}
