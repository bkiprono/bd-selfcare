import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:bdcomputing/components/currency/currency_selection_icon.dart';
import 'package:bdcomputing/core/routes.dart';
import 'package:bdcomputing/core/styles.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool showCurrencyIcon;
  final bool showProfileIcon;
  final bool showBackButton;

  const Header({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.showCurrencyIcon = true,
    this.showProfileIcon = true,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.sage100,
      elevation: 0,
      leading:
          leading ??
          (showBackButton
              ? (Navigator.of(context).canPop()
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.of(context).maybePop();
                      },
                    )
                  : IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil(
                            AppRoutes.home, (route) => false);
                      },
                    ))
              : null),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.blueGrey,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      centerTitle: centerTitle,
      actions: [
        if (showCurrencyIcon) const CurrencySelectorIcon(),
        if (showProfileIcon)const SizedBox(width: 16),
        if (showProfileIcon)InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(AppRoutes.profile);
          },
          child: const CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary,
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedUser02,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],

      iconTheme: const IconThemeData(color: AppColors.primary),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
