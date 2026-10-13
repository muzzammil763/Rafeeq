import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';

class RafeeqAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RafeeqAppBar({
    super.key,
    required this.title,
    required this.palette,
    this.titleWidget,
    this.showBackButton = false,
    this.onBack,
    this.actions,
    this.bottom,
  });

  final String title;
  final SettingsPalette palette;
  final Widget? titleWidget;
  final bool showBackButton;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize =>
      Size.fromHeight(57 + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';
    final bottomHeight = bottom?.preferredSize.height ?? 0;
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: palette.background,
      foregroundColor: palette.title,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: Theme.of(context).brightness == Brightness.light
          ? SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: palette.background,
            )
          : SystemUiOverlayStyle.light.copyWith(
              statusBarColor: palette.background,
            ),
      toolbarHeight: 56,
      elevation: 0,
      leadingWidth: showBackButton ? 56 : null,
      leading: showBackButton
          ? IconButton(
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded, size: 24),
            )
          : null,
      titleSpacing: showBackButton ? 0 : 12,
      centerTitle: false,
      title:
          titleWidget ??
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: palette.title,
              fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : 'GoogleSans',
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1 + bottomHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(height: 1, color: palette.divider),
            ?bottom,
          ],
        ),
      ),
    );
  }
}
