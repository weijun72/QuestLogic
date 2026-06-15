import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AvatarWidget extends StatefulWidget {
  final double size;
  final String? url;
  final void Function(String filePath) onUpload;

  const AvatarWidget({
    super.key,
    required this.size,
    required this.url,
    required this.onUpload,
  });

  @override
  State<AvatarWidget> createState() => _AvatarWidgetState();
}

class _AvatarWidgetState extends State<AvatarWidget> {
  bool _uploading = false;
  String? _signedUrl;

  @override
  void initState() {
    super.initState();
    if (widget.url != null) _downloadImage(widget.url!);
  }

  @override
  void didUpdateWidget(AvatarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.url != oldWidget.url && widget.url != null) {
      _downloadImage(widget.url!);
    }
  }

  Future<void> _downloadImage(String path) async {
    try {
      final signedUrl = await Supabase.instance.client.storage
          .from('avatars')
          .createSignedUrl(path, 604800);
      if (mounted) setState(() => _signedUrl = signedUrl);
    } catch (e) {
      debugPrint('Error getting image URL: $e');
    }
  }

  Future<void> _uploadAvatar() async {
    try {
      setState(() => _uploading = true);

      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 100,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();
      final fileExt = image.path.split('.').last.toLowerCase();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await Supabase.instance.client.storage
          .from('avatars')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/$fileExt',
              upsert: true,
            ),
          );

      widget.onUpload(fileName);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;

    return Column(
      children: [
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: _signedUrl != null
                ? Image.network(
                    _signedUrl!,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: size,
                      height: size,
                      color: const Color(0xFF333333),
                    ),
                  )
                : Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: const Color(0xFF333333),
                      border: Border.all(color: const Color(0xFFC8C8C8)),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _uploading ? null : _uploadAvatar,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6b5a48),
            disabledBackgroundColor: const Color(
              0xFF6b5a48,
            ).withValues(alpha: 0.5),
            padding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: Text(
            _uploading ? 'Uploading ...' : 'Upload',
            style: const TextStyle(
              color: Color(0xFFe7d8c9),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
