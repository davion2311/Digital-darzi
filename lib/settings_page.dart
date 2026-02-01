// lib/settings_page.dart
// ✅ LIGHT MODE: White buttons, Black text/icons, Border + Text Shimmer
// ✅ DARK MODE: Gold buttons (unchanged), Black text/icons, Border + Text Shimmer

import 'package:flutter/material.dart';

import 'app_localizations.dart';
import 'app_settings.dart';
import 'language_page.dart';
import 'ui_kit.dart';
import 'settings_header.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  bool get _isDark => AppSettings.darkModeVN.value;
  bool get _shimmerOn => AppSettings.shimmerVN.value;
  Color get _pageBg => _isDark ? Colors.black : Colors.white;
  String? get _currentFont => AppSettings.fontFamilyVN.value;

  @override
  void initState() {
    super.initState();

    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );

    _syncAnimWithShimmer();
    AppSettings.shimmerVN.addListener(_syncAnimWithShimmer);
    AppSettings.darkModeVN.addListener(_rebuild);
    AppSettings.fontFamilyVN.addListener(_rebuild);
  }

  void _rebuild() {
    if (!mounted) return;
    setState(() {});
  }

  void _syncAnimWithShimmer() {
    if (!mounted) return;

    if (_shimmerOn) {
      if (!_anim.isAnimating) _anim.repeat();
    } else {
      if (_anim.isAnimating) _anim.stop();
      _anim.value = 0.0;
    }

    setState(() {});
  }

  @override
  void dispose() {
    AppSettings.shimmerVN.removeListener(_syncAnimWithShimmer);
    AppSettings.darkModeVN.removeListener(_rebuild);
    AppSettings.fontFamilyVN.removeListener(_rebuild);
    _anim.dispose();
    super.dispose();
  }

  void _openGeneral() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GeneralSettingsPage()),
    );
  }

  void _openManualBackup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ManualBackupPage()),
    );
  }

  void _openAbout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AboutAppPage()),
    );
  }

  void _openContact() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ContactUsPage()),
    );
  }

  void _openGoToPro() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GoToProPage()),
    );
  }

  void _logout() {
    final loc = AppLocalizations.t(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${loc.logout} (coming soon)',
          style: TextStyle(fontFamily: _currentFont),
        ),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.t(context);
    
    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: Column(
          children: [
            SettingsHeader(
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 22),
                child: Column(
                  children: [
                    // 1) DARK MODE (FREE)
                    ValueListenableBuilder<bool>(
                      valueListenable: AppSettings.darkModeVN,
                      builder: (_, v, __) => _GoldCapsuleSettingTile(
                        anim: _anim,
                        shimmerOn: _shimmerOn,
                        isDark: _isDark, // ✅ PASSED
                        icon: Icons.dark_mode_rounded,
                        title: loc.darkMode.toUpperCase(),
                        fontFamily: _currentFont,
                        trailing: Switch(
                          value: v,
                          onChanged: (nv) => AppSettings.setDarkMode(nv),
                        ),
                        onTap: null,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 2) SHIMMER ANIMATION (FREE)
                    ValueListenableBuilder<bool>(
                      valueListenable: AppSettings.shimmerVN,
                      builder: (_, v, __) => _GoldCapsuleSettingTile(
                        anim: _anim,
                        shimmerOn: _shimmerOn,
                        isDark: _isDark, // ✅ PASSED
                        icon: Icons.auto_awesome_rounded,
                        title: loc.shimmerAnimation.toUpperCase(),
                        fontFamily: _currentFont,
                        trailing: Switch(
                          value: v,
                          onChanged: (nv) => AppSettings.setShimmer(nv),
                        ),
                        onTap: null,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 3) MANUAL BACKUP (FREE)
                    _GoldCapsuleSettingTile(
                      anim: _anim,
                      shimmerOn: _shimmerOn,
                      isDark: _isDark, // ✅ PASSED
                      icon: Icons.backup_rounded,
                      title: loc.manualBackup.toUpperCase(),
                      fontFamily: _currentFont,
                      trailing: const Icon(Icons.arrow_forward_ios_rounded,
                          size: 18, color: Colors.black),
                      onTap: _openManualBackup,
                    ),
                    const SizedBox(height: 12),

                    // 4) GENERAL
                    _GoldCapsuleSettingTile(
                      anim: _anim,
                      shimmerOn: _shimmerOn,
                      isDark: _isDark, // ✅ PASSED
                      icon: Icons.tune_rounded,
                      title: loc.general.toUpperCase(),
                      fontFamily: _currentFont,
                      trailing: const Icon(Icons.arrow_forward_ios_rounded,
                          size: 18, color: Colors.black),
                      onTap: _openGeneral,
                    ),
                    const SizedBox(height: 12),

                    // 5) ABOUT APP (FREE)
                    _GoldCapsuleSettingTile(
                      anim: _anim,
                      shimmerOn: _shimmerOn,
                      isDark: _isDark, // ✅ PASSED
                      icon: Icons.info_rounded,
                      title: loc.aboutApp.toUpperCase(),
                      fontFamily: _currentFont,
                      trailing: const Icon(Icons.arrow_forward_ios_rounded,
                          size: 18, color: Colors.black),
                      onTap: _openAbout,
                    ),
                    const SizedBox(height: 12),

                    // 6) CONTACT US (FREE)
                    _GoldCapsuleSettingTile(
                      anim: _anim,
                      shimmerOn: _shimmerOn,
                      isDark: _isDark, // ✅ PASSED
                      icon: Icons.contacts_rounded,
                      title: loc.contactUs.toUpperCase(),
                      fontFamily: _currentFont,
                      trailing: const Icon(Icons.arrow_forward_ios_rounded,
                          size: 18, color: Colors.black),
                      onTap: _openContact,
                    ),
                    const SizedBox(height: 12),

                    // 7) GO TO PRO (CTA)
                    _GoldCapsuleSettingTile(
                      anim: _anim,
                      shimmerOn: _shimmerOn,
                      isDark: _isDark, // ✅ PASSED
                      icon: Icons.workspace_premium_rounded,
                      title: loc.goToPro.toUpperCase(),
                      fontFamily: _currentFont,
                      trailing: const Icon(Icons.arrow_forward_ios_rounded,
                          size: 18, color: Colors.black),
                      onTap: _openGoToPro,
                    ),
                    const SizedBox(height: 12),

                    // 8) LOGOUT
                    _GoldCapsuleSettingTile(
                      anim: _anim,
                      shimmerOn: _shimmerOn,
                      isDark: _isDark, // ✅ PASSED
                      icon: Icons.logout_rounded,
                      title: loc.logout.toUpperCase(),
                      fontFamily: _currentFont,
                      trailing: const Icon(Icons.arrow_forward_ios_rounded,
                          size: 18, color: Colors.black),
                      onTap: _logout,
                    ),
                    const SizedBox(height: 18),

                    // Bottom text with shimmer
                    AnimatedBuilder(
                      animation: _anim,
                      builder: (_, __) => Opacity(
                        opacity: 0.85,
                        child: GoldTextShimmer(
                          text: loc.settingsReady,
                          t: _anim.value,
                          fontSize: 13.0,
                          letterSpacing: 1.1,
                          align: TextAlign.center,
                          fontFamily: _currentFont,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================= GENERAL SETTINGS PAGE =======================

class GeneralSettingsPage extends StatefulWidget {
  const GeneralSettingsPage({super.key});

  @override
  State<GeneralSettingsPage> createState() => _GeneralSettingsPageState();
}

class _GeneralSettingsPageState extends State<GeneralSettingsPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  bool get _isDark => AppSettings.darkModeVN.value;
  bool get _shimmerOn => AppSettings.shimmerVN.value;
  Color get _pageBg => _isDark ? Colors.black : Colors.white;
  String? get _currentFont => AppSettings.fontFamilyVN.value;

  bool _autoBackupOn = false;
  bool _fontsExpanded = false;

  static const List<String> kAppFonts = <String>[
    'DEFAULT',
    'AASameer',
    'Aadil',
    'AlFars',
    'BlakaHollow',
    'BlakaInk',
    'CairoPlay',
    'Inter',
    'Katibeh',
    'Montserrat',
    'Nabla',
    'NotoSans',
    'NotoSerif',
    'Oi',
    'ReemKufiFun',
    'ReemKufiInk',
    'Roboto',
  ];

  @override
  void initState() {
    super.initState();

    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );

    _syncAnimWithShimmer();
    AppSettings.shimmerVN.addListener(_syncAnimWithShimmer);
    AppSettings.darkModeVN.addListener(_rebuild);
    AppSettings.fontFamilyVN.addListener(_rebuild);
  }

  void _rebuild() {
    if (!mounted) return;
    setState(() {});
  }

  void _syncAnimWithShimmer() {
    if (!mounted) return;

    if (_shimmerOn) {
      if (!_anim.isAnimating) _anim.repeat();
    } else {
      if (_anim.isAnimating) _anim.stop();
      _anim.value = 0.0;
    }

    setState(() {});
  }

  @override
  void dispose() {
    AppSettings.shimmerVN.removeListener(_syncAnimWithShimmer);
    AppSettings.darkModeVN.removeListener(_rebuild);
    AppSettings.fontFamilyVN.removeListener(_rebuild);
    _anim.dispose();
    super.dispose();
  }

  void _toastPro() {
    final loc = AppLocalizations.t(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          loc.proFeature,
          style: TextStyle(fontFamily: _currentFont),
        ),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _openLanguage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LanguagePage()),
    );
  }

  void _openReceiptTemplate() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReceiptTemplatePage()),
    );
  }

  void _openProfilePictureFrame() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfilePictureFramePage()),
    );
  }

  void _openPremiumFeatures() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PremiumFeaturesPage()),
    );
  }

  Future<void> _selectFont(String family) async {
    final loc = AppLocalizations.t(context);
    if (family == 'DEFAULT') {
      await AppSettings.setFontFamily(null);
    } else {
      await AppSettings.setFontFamily(family);
    }

    if (!mounted) return;
    setState(() => _fontsExpanded = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          loc.fontApplied(family.toUpperCase()),
          style: TextStyle(fontFamily: _currentFont),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  String get _currentFontLabel {
    final f = AppSettings.fontFamilyVN.value;
    if (f == null || f.trim().isEmpty) {
      return AppLocalizations.t(context).defaultStr;
    }
    return f.trim();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.t(context);
    final current = _currentFontLabel;

    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: Column(
          children: [
            SettingsHeader(onBack: () => Navigator.pop(context)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 22),
                child: Column(
                  children: [
                    // AUTO BACKUP (PRO)
                    _GoldCapsuleSettingTile(
                      anim: _anim,
                      shimmerOn: _shimmerOn,
                      isDark: _isDark, // ✅ PASSED
                      icon: Icons.backup_rounded,
                      title: loc.autoBackup.toUpperCase(),
                      fontFamily: _currentFont,
                      trailing: Switch(
                        value: _autoBackupOn,
                        onChanged: null,
                      ),
                      onTap: _toastPro,
                    ),
                    const SizedBox(height: 12),

                    // LANGUAGE (FREE)
                    _GoldCapsuleSettingTile(
                      anim: _anim,
                      shimmerOn: _shimmerOn,
                      isDark: _isDark, // ✅ PASSED
                      icon: Icons.language_rounded,
                      title: loc.language.toUpperCase(),
                      fontFamily: _currentFont,
                      trailing: const Icon(Icons.arrow_forward_ios_rounded,
                          size: 18, color: Colors.black),
                      onTap: _openLanguage,
                    ),
                    const SizedBox(height: 12),

                    // FONTS (Selectable)
                    _GoldCapsuleSettingTile(
                      anim: _anim,
                      shimmerOn: _shimmerOn,
                      isDark: _isDark, // ✅ PASSED
                      icon: Icons.font_download_rounded,
                      title: loc.fonts.toUpperCase(),
                      fontFamily: _currentFont,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            current.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 11.5,
                              fontFamily: _currentFont,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _fontsExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            size: 22,
                            color: Colors.black,
                          ),
                        ],
                      ),
                      onTap: () =>
                          setState(() => _fontsExpanded = !_fontsExpanded),
                    ),

                    if (_fontsExpanded) ...[
                      const SizedBox(height: 12),
                      ...kAppFonts.map((f) {
                        final selected = (f == 'DEFAULT' &&
                                AppSettings.fontFamilyVN.value == null) ||
                            (AppSettings.fontFamilyVN.value == f);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _GoldCapsuleSettingTile(
                            anim: _anim,
                            shimmerOn: _shimmerOn,
                            isDark: _isDark, // ✅ PASSED
                            icon: Icons.text_fields_rounded,
                            title: f == 'DEFAULT' 
                                ? loc.defaultStr 
                                : f,
                            fontFamily: f == 'DEFAULT' ? null : f,
                            trailing: Icon(
                              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                              size: 20,
                              color: Colors.black,
                            ),
                            onTap: () => _selectFont(f),
                          ),
                        );
                      }).toList(),
                    ],

                    const SizedBox(height: 12),

                    // RESTORE (PRO)
                    _GoldCapsuleSettingTile(
                      anim: _anim,
                      shimmerOn: _shimmerOn,
                      isDark: _isDark, // ✅ PASSED
                      icon: Icons.restore_rounded,
                      title: loc.restore.toUpperCase(),
                      fontFamily: _currentFont,
                      trailing: const Icon(Icons.arrow_forward_ios_rounded,
                          size: 18, color: Colors.black),
                      onTap: _toastPro,
                    ),
                    const SizedBox(height: 12),

                    // RECEIPT (PRO)
                    _GoldCapsuleSettingTile(
                      anim: _anim,
                      shimmerOn: _shimmerOn,
                      isDark: _isDark, // ✅ PASSED
                      icon: Icons.receipt_long_rounded,
                      title: loc.receipt.toUpperCase(),
                      fontFamily: _currentFont,
                      trailing: const Icon(Icons.arrow_forward_ios_rounded,
                          size: 18, color: Colors.black),
                      onTap: _toastPro,
                    ),
                    const SizedBox(height: 12),

                    // RESET SETTINGS (PRO)
                    _GoldCapsuleSettingTile(
                      anim: _anim,
                      shimmerOn: _shimmerOn,
                      isDark: _isDark, // ✅ PASSED
                      icon: Icons.restart_alt_rounded,
                      title: loc.resetSettings.toUpperCase(),
                      fontFamily: _currentFont,
                      trailing: const Icon(Icons.arrow_forward_ios_rounded,
                          size: 18, color: Colors.black),
                      onTap: _toastPro,
                    ),
                    const SizedBox(height: 12),

                    // RECEIPT TEMPLATE (NEW)
                    _GoldCapsuleSettingTile(
                      anim: _anim,
                      shimmerOn: _shimmerOn,
                      isDark: _isDark, // ✅ PASSED
                      icon: Icons.receipt_rounded,
                      title: loc.receiptTemplate.toUpperCase(),
                      fontFamily: _currentFont,
                      trailing: const Icon(Icons.arrow_forward_ios_rounded,
                          size: 18, color: Colors.black),
                      onTap: _openReceiptTemplate,
                    ),
                    const SizedBox(height: 12),

                    // PROFILE PICTURE FRAME (NEW)
                    _GoldCapsuleSettingTile(
                      anim: _anim,
                      shimmerOn: _shimmerOn,
                      isDark: _isDark, // ✅ PASSED
                      icon: Icons.account_circle_rounded,
                      title: loc.profilePictureFrame.toUpperCase(),
                      fontFamily: _currentFont,
                      trailing: const Icon(Icons.arrow_forward_ios_rounded,
                          size: 18, color: Colors.black),
                      onTap: _openProfilePictureFrame,
                    ),
                    const SizedBox(height: 12),

                    // PREMIUM FEATURES (NEW)
                    _GoldCapsuleSettingTile(
                      anim: _anim,
                      shimmerOn: _shimmerOn,
                      isDark: _isDark, // ✅ PASSED
                      icon: Icons.diamond_rounded,
                      title: loc.premiumFeatures.toUpperCase(),
                      fontFamily: _currentFont,
                      trailing: const Icon(Icons.arrow_forward_ios_rounded,
                          size: 18, color: Colors.black),
                      onTap: _openPremiumFeatures,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================= PLACEHOLDER PAGES =======================

class ManualBackupPage extends StatelessWidget {
  const ManualBackupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.t(context);
    final isDark = AppSettings.darkModeVN.value;
    final font = AppSettings.fontFamilyVN.value;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SettingsHeader(onBack: () => Navigator.pop(context)),
            Expanded(
              child: Center(
                child: Text(
                  '${loc.manualBackup}\n(${loc.comingSoon})',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black, // ✅ BLACK in light
                    fontFamily: font,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.t(context);
    final isDark = AppSettings.darkModeVN.value;
    final font = AppSettings.fontFamilyVN.value;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SettingsHeader(onBack: () => Navigator.pop(context)),
            Expanded(
              child: Center(
                child: Text(
                  '${loc.aboutApp}\n(${loc.comingSoon})',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black, // ✅ BLACK in light
                    fontFamily: font,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.t(context);
    final isDark = AppSettings.darkModeVN.value;
    final font = AppSettings.fontFamilyVN.value;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SettingsHeader(onBack: () => Navigator.pop(context)),
            Expanded(
              child: Center(
                child: Text(
                  '${loc.contactUs}\n(${loc.comingSoon})',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black, // ✅ BLACK in light
                    fontFamily: font,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GoToProPage extends StatelessWidget {
  const GoToProPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.t(context);
    final isDark = AppSettings.darkModeVN.value;
    final font = AppSettings.fontFamilyVN.value;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SettingsHeader(onBack: () => Navigator.pop(context)),
            Expanded(
              child: Center(
                child: Text(
                  '${loc.goToPro}\n(${loc.comingSoon})',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black, // ✅ BLACK in light
                    fontFamily: font,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReceiptTemplatePage extends StatelessWidget {
  const ReceiptTemplatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.t(context);
    final isDark = AppSettings.darkModeVN.value;
    final font = AppSettings.fontFamilyVN.value;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SettingsHeader(onBack: () => Navigator.pop(context)),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_rounded, size: 64, color: isDark ? Colors.white24 : Colors.black26),
                    const SizedBox(height: 16),
                    Text(
                      loc.receiptTemplate,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black, // ✅ BLACK in light
                        fontFamily: font,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.comingSoon,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontFamily: font,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePictureFramePage extends StatelessWidget {
  const ProfilePictureFramePage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.t(context);
    final isDark = AppSettings.darkModeVN.value;
    final font = AppSettings.fontFamilyVN.value;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SettingsHeader(onBack: () => Navigator.pop(context)),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.account_circle_rounded, size: 64, color: isDark ? Colors.white24 : Colors.black26),
                    const SizedBox(height: 16),
                    Text(
                      loc.profilePictureFrame,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black, // ✅ BLACK in light
                        fontFamily: font,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.comingSoon,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontFamily: font,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PremiumFeaturesPage extends StatelessWidget {
  const PremiumFeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.t(context);
    final isDark = AppSettings.darkModeVN.value;
    final font = AppSettings.fontFamilyVN.value;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SettingsHeader(onBack: () => Navigator.pop(context)),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.diamond_rounded, size: 64, color: isDark ? Colors.white24 : Colors.black26),
                    const SizedBox(height: 16),
                    Text(
                      loc.premiumFeatures,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black, // ✅ BLACK in light
                        fontFamily: font,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.comingSoon,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontFamily: font,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================= UPDATED GOLD CAPSULE TILE =======================

class _GoldCapsuleSettingTile extends StatelessWidget {
  final AnimationController anim;
  final bool shimmerOn;
  final bool isDark; // ✅ NEW: To handle light/dark mode colors
  final IconData icon;
  final String title;
  final Widget trailing;
  final VoidCallback? onTap;
  final String? fontFamily;

  const _GoldCapsuleSettingTile({
    required this.anim,
    required this.shimmerOn,
    required this.isDark, // ✅ REQUIRED NOW
    required this.icon,
    required this.title,
    required this.trailing,
    required this.onTap,
    this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    final t = shimmerOn ? anim.value : 0.0;

    return AnimatedBuilder(
      animation: anim,
      builder: (_, __) {
        return GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: CustomPaint(
            painter: BorderShimmerPainter(
              t: t,
              radius: 999,
              strokeWidth: 3.2,
            ),
            child: Container(
              height: 62,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                // ✅ KEY CHANGE: White in light mode, Gold gradient in dark mode
                color: isDark ? null : Colors.white,
                gradient: isDark ? const LinearGradient(
                  colors: masterGoldGradient,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ) : null,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26, // Slightly lighter shadow for white buttons
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // ✅ Icon always black as requested
                  Icon(icon, color: Colors.black, size: 26),
                  const SizedBox(width: 12),

                  // ✅ Title with shimmer animation on text
                  Expanded(
                    child: shimmerOn
                        ? GoldTextShimmer(
                            text: title,
                            t: t,
                            fontSize: 15.2,
                            letterSpacing: 1.0,
                            align: TextAlign.left,
                            fontFamily: fontFamily,
                          )
                        : Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black, // ✅ Always black text
                              fontFamily: fontFamily,
                              fontSize: 15.2,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                  ),

                  const SizedBox(width: 10),
                  Theme(
                    data: Theme.of(context).copyWith(
                      switchTheme: const SwitchThemeData(
                        thumbColor: WidgetStatePropertyAll(Colors.black),
                        trackColor: WidgetStatePropertyAll(Colors.white),
                        trackOutlineColor: WidgetStatePropertyAll(Colors.black),
                      ),
                    ),
                    child: trailing,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}