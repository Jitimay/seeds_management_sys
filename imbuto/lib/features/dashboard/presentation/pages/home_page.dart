import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:imbuto/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:imbuto/features/auth/presentation/bloc/auth_event.dart';
import 'package:imbuto/features/auth/presentation/bloc/auth_state.dart';
import 'package:imbuto/features/ratings/presentation/bloc/rating_bloc.dart';
import 'package:imbuto/features/ratings/presentation/widgets/rating_widgets.dart';
import 'package:imbuto/shared/services/service_locator.dart';
import 'package:imbuto/features/ratings/domain/entities/rating.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'IMBUTO',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
              context.go('/login');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return BlocProvider(
                create: (context) =>
                    ServiceLocator.get<RatingBloc>()..add(LoadRatings()),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWelcomeSection(state.user),
                        const SizedBox(height: 30),
                        _buildQuickActions(context, state.user),
                        const SizedBox(height: 30),
                        _buildRecentActivity(context),
                        const SizedBox(height: 30),
                        _buildRatingsSection(context),
                        const SizedBox(
                            height: 100), // Space for floating nav bar
                      ],
                    ),
                  ),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(Map<String, dynamic> user) {
    final bool isValidated = user['is_validated'] ?? false;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.green.withOpacity(0.1),
                child: const Icon(Icons.person_rounded,
                    size: 35, color: Colors.green),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Salut,',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    Text(
                      '${user['first_name'] ?? 'Utilisateur'} ${user['last_name'] ?? ''}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(isValidated),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.work_rounded, user['role'] ?? 'Multiplicateur'),
          if (user['province'] != null)
            _buildInfoRow(Icons.location_on_rounded,
                '${user['province']}, ${user['commune']}'),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isValidated) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isValidated
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isValidated ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isValidated ? Icons.check_circle_rounded : Icons.pending_rounded,
            size: 14,
            color: isValidated ? Colors.green[700] : Colors.orange[700],
          ),
          const SizedBox(width: 4),
          Text(
            isValidated ? 'Validé' : 'En attente',
            style: TextStyle(
              color: isValidated ? Colors.green[800] : Colors.orange[800],
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(color: Colors.grey[800], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, Map<String, dynamic> user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Services essentiels',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.1,
              children: [
                _buildModernActionCard(
                  context,
                  'STOCKS',
                  Icons.inventory_2_rounded,
                  [Colors.green, Colors.teal],
                  () => context.go('/stocks'),
                ),
                _buildModernActionCard(
                  context,
                  'COMMANDES',
                  Icons.shopping_bag_rounded,
                  [Colors.blue, Colors.indigo],
                  () => context.go('/orders'),
                ),
                _buildModernActionCard(
                  context,
                  'PLANTES',
                  Icons.eco_rounded,
                  [Colors.teal, Colors.tealAccent.shade700],
                  () => context.go('/plants'),
                ),
                _buildModernActionCard(
                  context,
                  'PERTES',
                  Icons.report_problem_rounded,
                  [Colors.orange, Colors.red],
                  () => context.go('/losses'),
                ),
                if (user['role'] == 'superuser' || user['role'] == 'admin')
                  _buildModernActionCard(
                    context,
                    'ADMIN',
                    Icons.admin_panel_settings_rounded,
                    [Colors.purple, Colors.deepPurple],
                    () => context.go('/admin'),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildModernActionCard(
    BuildContext context,
    String title,
    IconData icon,
    List<Color> colors,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors[0].withOpacity(0.8),
              colors[1].withOpacity(0.6),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actitivé récente',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 15),
        GlassCard(
          child: Column(
            children: [
              Icon(Icons.auto_graph_rounded, size: 40, color: Colors.grey[400]),
              const SizedBox(height: 10),
              Text(
                'Pas encore d\'activité',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Vos ventes et stocks apparaîtront ici.',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Avis et évaluations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to all reviews
              },
              child: const Text('Tout voir'),
            ),
          ],
        ),
        const SizedBox(height: 5),
        BlocBuilder<RatingBloc, RatingState>(
          builder: (context, state) {
            if (state is RatingLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (state is RatingLoaded) {
              if (state.ratings.isEmpty) {
                return GlassCard(
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.star_outline_rounded,
                            size: 40, color: Colors.grey[400]),
                        const SizedBox(height: 10),
                        Text(
                          'Aucun avis pour le moment',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.ratings.length > 3 ? 3 : state.ratings.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final rating = state.ratings[index];
                  return _buildRatingItem(rating);
                },
              );
            } else if (state is RatingError) {
              return Center(
                child: Text(
                  'Erreur: ${state.message}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }

  Widget _buildRatingItem(Rating rating) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.green.withOpacity(0.1),
                    child:
                        const Icon(Icons.person, size: 14, color: Colors.green),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    rating.createdBy ?? 'Utilisateur',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              RatingStars(
                rating: rating.etoiles.toDouble(),
                size: 14,
                allowHalfRating: false,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (rating.stockVariety != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                rating.stockVariety!,
                style: TextStyle(
                  color: Colors.green[700],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (rating.commentaire != null && rating.commentaire!.isNotEmpty)
            Text(
              rating.commentaire!,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
                height: 1.4,
              ),
            ),
          const SizedBox(height: 8),
          Text(
            _formatDate(rating.createdAt),
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays < 1) {
      if (diff.inHours < 1) {
        return 'Il y a ${diff.inMinutes} min';
      }
      return 'Il y a ${diff.inHours} h';
    }
    if (diff.inDays < 7) {
      return 'Il y a ${diff.inDays} j';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const GlassCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
