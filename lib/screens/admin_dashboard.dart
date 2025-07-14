import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/theme_notifier.dart';
import 'product_management.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final Color primaryColor =
        isDarkMode ? Colors.grey[900]! : const Color(0xFFfeada6);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beauty Products Admin'),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: () => themeProvider.toggleTheme(
                !isDarkMode), // Fixed: Added the required bool parameter
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      drawer: _buildDrawer(context, isDarkMode, primaryColor),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [const Color(0xFF424242), const Color(0xFF303030)]
                : [const Color(0xFFf5efef), const Color(0xFFfeada6)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Product Management',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildProductCard(
                      context,
                      icon: Icons.brush,
                      title: 'Lipsticks',
                      color: Colors.red[300]!,
                      onTap: () =>
                          _navigateToProductManagement(context, 'lipstick'),
                    ),
                    _buildProductCard(
                      context,
                      icon: Icons.face,
                      title: 'Eyebrows',
                      color: Colors.brown[300]!,
                      onTap: () =>
                          _navigateToProductManagement(context, 'eyebrow'),
                    ),
                    _buildProductCard(
                      context,
                      icon: Icons.color_lens,
                      title: 'Foundations',
                      color: Colors.orange[300]!,
                      onTap: () =>
                          _navigateToProductManagement(context, 'foundation'),
                    ),
                    _buildProductCard(
                      context,
                      icon: Icons.brush_outlined,
                      title: 'Nail Paints',
                      color: Colors.pink[300]!,
                      onTap: () =>
                          _navigateToProductManagement(context, 'nailpaint'),
                    ),
                  ],
                ),
              ),
              // Uncomment if you want to use the stats section
              _buildStatsSection(context, isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(
      BuildContext context, bool isDarkMode, Color primaryColor) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Image.asset(
                    'assets/logo.png',
                    height: 40,
                    width: 40,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  FirebaseAuth.instance.currentUser?.email ?? '',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.dashboard,
            title: 'Dashboard',
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Product Management',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.brush,
            title: 'Lipsticks',
            onTap: () => _navigateToProductManagement(context, 'lipstick'),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.face,
            title: 'Eyebrows',
            onTap: () => _navigateToProductManagement(context, 'eyebrow'),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.color_lens,
            title: 'Foundations',
            onTap: () => _navigateToProductManagement(context, 'foundation'),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.brush_outlined,
            title: 'Nailpaints',
            onTap: () => _navigateToProductManagement(context, 'nailpaint'),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _buildProductCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isDarkMode ? Colors.grey[800] : color.withOpacity(0.2),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[700] : color,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // This method is currently not used (commented out in the build method)
  // Uncomment and call it if you need to display stats
  Widget _buildStatsSection(BuildContext context, bool isDarkMode) {
    return Card(
      elevation: 4,
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Stats',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                    context, 'Total Products', '142', Icons.shopping_bag),
                _buildStatItem(context, 'New Today', '5', Icons.new_releases),
                _buildStatItem(context, 'Low Stock', '3', Icons.warning),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, String label, String value, IconData icon) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Icon(icon, color: isDarkMode ? Colors.amber : const Color(0xFFfeada6)),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }

  void _navigateToProductManagement(BuildContext context, String productType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductManagement(productType: productType),
      ),
    );
  }
}
