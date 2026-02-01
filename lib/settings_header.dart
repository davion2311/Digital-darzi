// lib/settings_header.dart
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

import 'ui_kit.dart';

/// ✅ FULL HEADER MODULE (LOCKED)
/// - Profile load/save inside header
/// - Image pick from gallery
/// - Custom crop page (pinch zoom + drag)
/// - Edit dialog includes: Choose photo + Name + Phone + About
/// - Shimmer border on profile circle + edit button + texts
class SettingsHeader extends StatefulWidget {
  final VoidCallback onBack;

  const SettingsHeader({
    super.key,
    required this.onBack,
  });

  @override
  State<SettingsHeader> createState() => _SettingsHeaderState();
}

class _SettingsHeaderState extends State<SettingsHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  String _name = "WAQAR TAILOR'S";
  String _phone = '';
  String _about = '';

  Uint8List? _profileBytes;

  // ✅ profile keys (header-only)
  static const _kName = 'settings_profile_name_v3';
  static const _kPhone = 'settings_profile_phone_v3';
  static const _kAbout = 'settings_profile_about_v3';
  static const _kProfileB64 = 'settings_profile_photo_b64_v3';

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat();

    _loadProfile();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(_kName);
      final phone = prefs.getString(_kPhone);
      final about = prefs.getString(_kAbout);
      final b64 = prefs.getString(_kProfileB64);

      if (!mounted) return;
      setState(() {
        if (name != null && name.trim().isNotEmpty) _name = name.trim();
        _phone = (phone ?? '').trim();
        _about = (about ?? '').trim();
        _profileBytes = (b64 == null || b64.isEmpty) ? null : base64Decode(b64);
      });
    } catch (_) {}
  }

  Future<void> _saveProfile({
    required String name,
    required String phone,
    required String about,
    required Uint8List? bytes,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kName, name.trim());
      await prefs.setString(_kPhone, phone.trim());
      await prefs.setString(_kAbout, about.trim());

      if (bytes == null) {
        await prefs.remove(_kProfileB64);
      } else {
        await prefs.setString(_kProfileB64, base64Encode(bytes));
      }
    } catch (_) {}
  }

  String _initials(String s) {
    final t = s.trim();
    if (t.isEmpty) return 'DD';
    final parts = t.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'DD';
    final first = parts.first;
    final last = parts.length >= 2 ? parts.last : '';
    final a = first.isNotEmpty ? first[0] : 'D';
    final b = last.isNotEmpty ? last[0] : (first.length >= 2 ? first[1] : 'D');
    return (a + b).toUpperCase();
  }

  Future<Uint8List?> _pickFromGalleryBytes() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 92,
      );
      if (picked == null) return null;
      return await picked.readAsBytes();
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gallery error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  Future<void> _editProfile() async {
    final nameCtrl = TextEditingController(text: _name);
    final phoneCtrl = TextEditingController(text: _phone);
    final aboutCtrl = TextEditingController(text: _about);

    Uint8List? tempBytes = _profileBytes;

    final res = await showDialog<_ProfileResult>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              backgroundColor: Colors.black,
              surfaceTintColor: Colors.transparent,
              title: const Text(
                'EDIT PROFILE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    // ✅ Choose profile picture (gallery -> crop/drag/zoom)
                    GestureDetector(
                      onTap: () async {
                        final pickedBytes = await _pickFromGalleryBytes();
                        if (pickedBytes == null) return;

                        if (!mounted) return;
                        final cropped = await Navigator.push<Uint8List?>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => _CropSquarePage(
                              bytes: pickedBytes,
                              anim: _anim,
                            ),
                          ),
                        );

                        if (cropped == null) return;
                        setLocal(() => tempBytes = cropped);
                      },
                      child: _ShimmerBorder(
                        t: _anim.value,
                        radius: 999,
                        strokeWidth: 3.2,
                        child: Container(
                          height: 96,
                          width: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black,
                            image: tempBytes == null
                                ? null
                                : DecorationImage(
                                    image: MemoryImage(tempBytes!),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          child: tempBytes == null
                              ? Center(
                                  child: Text(
                                    'CHOOSE',
                                    style: TextStyle(
                                      color: const Color(0xFFD4AF37)
                                          .withOpacity(0.95),
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tap to choose photo',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _dialogField(
                      label: 'NAME',
                      controller: nameCtrl,
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: 12),
                    _dialogField(
                      label: 'PHONE',
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    _dialogField(
                      label: 'ABOUT',
                      controller: aboutCtrl,
                      keyboardType: TextInputType.text,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final n = nameCtrl.text.trim();
                    final p = phoneCtrl.text.trim();
                    final a = aboutCtrl.text.trim();

                    if (n.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Name خالی نہیں ہو سکتا'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    Navigator.pop(
                      ctx,
                      _ProfileResult(
                        name: n,
                        phone: p,
                        about: a,
                        bytes: tempBytes,
                      ),
                    );
                  },
                  child: const Text(
                    'SAVE',
                    style: TextStyle(
                      color: Color(0xFFD4AF37),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (!mounted || res == null) return;

    setState(() {
      _name = res.name;
      _phone = res.phone;
      _about = res.about;
      _profileBytes = res.bytes;
    });

    await _saveProfile(
      name: res.name,
      phone: res.phone,
      about: res.about,
      bytes: res.bytes,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile Updated ✅'),
        backgroundColor: Colors.green,
      ),
    );
  }

  static Widget _dialogField({
    required String label,
    required TextEditingController controller,
    required TextInputType keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
      ),
      cursorColor: const Color(0xFFD4AF37),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.18)),
          borderRadius: BorderRadius.circular(14),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
          borderRadius: BorderRadius.circular(14),
        ),
        filled: true,
        fillColor: const Color(0xFF0B0B0B),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _profileHeader();
  }

  Widget _profileHeader() {
    const headerH = 150.0;

    return SizedBox(
      height: headerH,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: masterGoldGradient,
                  stops: [0.0, 0.45, 0.72, 1.0],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(70),
                  bottomRight: Radius.circular(70),
                ),
              ),
            ),
          ),

          // ✅ Back icon RIGHT, no background
          Positioned(
            top: 10,
            right: 12,
            child: GestureDetector(
              onTap: widget.onBack,
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.black,
                size: 26,
              ),
            ),
          ),

          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: Row(
              children: [
                // ✅ Profile circle shimmer border
                _ShimmerBorder(
                  t: _anim.value,
                  radius: 999,
                  strokeWidth: 3.2,
                  child: Container(
                    height: 82,
                    width: 82,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                      image: _profileBytes == null
                          ? null
                          : DecorationImage(
                              image: MemoryImage(_profileBytes!),
                              fit: BoxFit.cover,
                            ),
                    ),
                    child: _profileBytes == null
                        ? Center(
                            child: _BlackShimmerText(
                              text: _initials(_name),
                              t: _anim.value,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),

                // ✅ Shimmer texts
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _BlackShimmerText(
                        text: _name,
                        t: _anim.value,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                      const SizedBox(height: 4),
                      _BlackShimmerText(
                        text: _phone.isEmpty ? 'PHONE: —' : 'PHONE: $_phone',
                        t: _anim.value,
                        fontSize: 12.7,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                      const SizedBox(height: 4),
                      _BlackShimmerText(
                        text: _about.isEmpty ? 'ABOUT: —' : 'ABOUT: $_about',
                        t: _anim.value,
                        fontSize: 12.2,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // ✅ Edit button shimmer border
                GestureDetector(
                  onTap: _editProfile,
                  child: _ShimmerBorder(
                    t: _anim.value,
                    radius: 999,
                    strokeWidth: 3.0,
                    child: Container(
                      height: 48,
                      width: 48,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Color(0xFFD4AF37),
                        size: 22,
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
  }
}

class _ProfileResult {
  final String name;
  final String phone;
  final String about;
  final Uint8List? bytes;

  _ProfileResult({
    required this.name,
    required this.phone,
    required this.about,
    required this.bytes,
  });
}

/// ✅ Shimmer border (uses your BorderShimmerPainter)
class _ShimmerBorder extends StatelessWidget {
  final double t;
  final double radius;
  final double strokeWidth;
  final Widget child;

  const _ShimmerBorder({
    required this.t,
    required this.radius,
    required this.strokeWidth,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BorderShimmerPainter(
        t: t,
        radius: radius,
        strokeWidth: strokeWidth,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: child,
      ),
    );
  }
}

/// ✅ Black shimmer text (always black, no shadow, no background)
class _BlackShimmerText extends StatelessWidget {
  final String text;
  final double t;
  final double fontSize;
  final FontWeight fontWeight;
  final double letterSpacing;

  const _BlackShimmerText({
    required this.text,
    required this.t,
    required this.fontSize,
    required this.fontWeight,
    required this.letterSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final base = Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        color: Colors.black, // ✅ ALWAYS BLACK
      ),
    );

    final begin = Alignment(-1.0 + 2.0 * t, -0.2);
    final end = Alignment(begin.x + 1.2, 0.2);

    return ShaderMask(
      shaderCallback: (rect) {
        return LinearGradient(
          begin: begin,
          end: end,
          colors: [
            Colors.black,
            Colors.black.withOpacity(0.45),
            Colors.black,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(rect);
      },
      blendMode: BlendMode.srcIn,
      child: base,
    );
  }
}

/// ✅ Custom crop page (square) — zoom + pan — returns cropped PNG bytes
class _CropSquarePage extends StatefulWidget {
  final Uint8List bytes;
  final AnimationController anim;

  const _CropSquarePage({
    required this.bytes,
    required this.anim,
  });

  @override
  State<_CropSquarePage> createState() => _CropSquarePageState();
}

class _CropSquarePageState extends State<_CropSquarePage> {
  final TransformationController _tc = TransformationController();
  final GlobalKey _cropKey = GlobalKey();

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  Future<Uint8List?> _exportCropped() async {
    try {
      final boundary =
          _cropKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      return byteData.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    const double cropSize = 260;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'CROP PHOTO',
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontWeight: FontWeight.w900,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final out = await _exportCropped();
              if (!mounted) return;
              Navigator.pop(context, out);
            },
            child: const Text(
              'DONE',
              style: TextStyle(
                color: Color(0xFFD4AF37),
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 18),
            AnimatedBuilder(
              animation: widget.anim,
              builder: (_, __) {
                return _ShimmerBorder(
                  t: widget.anim.value,
                  radius: 26,
                  strokeWidth: 3.2,
                  child: RepaintBoundary(
                    key: _cropKey,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: SizedBox(
                        width: cropSize,
                        height: cropSize,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Container(color: Colors.black),
                            InteractiveViewer(
                              transformationController: _tc,
                              minScale: 1.0,
                              maxScale: 6.0,
                              panEnabled: true,
                              scaleEnabled: true,
                              child: Image.memory(
                                widget.bytes,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            Text(
              'Pinch to zoom • Drag to move',
              style: TextStyle(
                color: Colors.white.withOpacity(0.65),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}