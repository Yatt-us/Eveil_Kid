// lib/features/panier/presentation/widgets/panier_app_bar_action.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/panier_provider.dart';

class PanierAppBarAction extends ConsumerWidget {
  const PanierAppBarAction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final userId = authState.utilisateur?.utilisateurId ?? '';

    if (userId.isEmpty) {
      return IconButton(
        icon: Icon(
          Icons.shopping_cart_outlined,
          color: theme.iconTheme.color ?? theme.colorScheme.onSurface,
          size: 24,
        ),
        tooltip: 'Mon Panier',
        onPressed: () => context.push(AppRoutes.panier),
      );
    }

    final panierAsync = ref.watch(panierProvider(userId));

    final totalArticles = panierAsync.when(
      data: (articles) => articles.length,
      loading: () => 0,
      error: (_, _) => 0,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(
            Icons.shopping_cart_outlined,
            color: theme.iconTheme.color ?? theme.colorScheme.onSurface,
            size: 24,
          ),
          tooltip: 'Mon Panier',
          onPressed: () => context.push(AppRoutes.panier),
        ),
        if (totalArticles > 0)
          Positioned(
            right: 6,
            top: 6,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: theme.scaffoldBackgroundColor,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    totalArticles > 99 ? '99+' : '$totalArticles',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
