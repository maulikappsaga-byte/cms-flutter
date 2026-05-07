import 'package:flutter/material.dart';
import '../theme.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  String _selectedFilter = 'Today';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _allAppointments = [
    {
      'token': 'TOKEN #104',
      'name': 'Eleanor Penhaligon',
      'status': 'Upcoming',
      'date': 'Oct 24, 2023',
      'time': '10:30 AM',
      'color': AppColors.primaryContainer,
      'showCheckIn': true,
    },
    {
      'token': 'TOKEN #102',
      'name': 'Arthur Sterling',
      'status': 'Completed',
      'date': 'Oct 24, 2023',
      'time': '09:15 AM',
      'color': const Color(0xFFE2E8F0),
      'statusColor': Colors.green,
    },
    {
      'token': 'TOKEN #105',
      'name': 'Clara Abernathy',
      'status': 'Waitlist',
      'date': 'Oct 24, 2023',
      'time': '11:00 AM',
      'color': Colors.amber,
      'statusColor': Colors.orange[700],
      'footer': 'Patient has arrived',
    },
    {
      'token': 'TOKEN #101',
      'name': 'Julian Vance',
      'status': 'No Show',
      'date': 'Oct 24, 2023',
      'time': '08:45 AM',
      'color': AppColors.error,
      'statusColor': AppColors.error,
      'opacity': 0.6,
    },
  ];

  List<Map<String, dynamic>> get _filteredAppointments {
    return _allAppointments.where((appointment) {
      final matchesSearch = appointment['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          appointment['token'].toLowerCase().contains(_searchQuery.toLowerCase());
      
      if (_selectedFilter == 'All') return matchesSearch;
      if (_selectedFilter == 'Today') return matchesSearch; // For demo, all are today
      if (_selectedFilter == 'Completed') return matchesSearch && appointment['status'] == 'Completed';
      
      return matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
        ),
        title: Text(
          'ClinicOS',
          style: textTheme.headlineMedium?.copyWith(
            fontSize: 20,
            color: AppColors.primaryContainer,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _selectedFilter = 'Today';
                _searchController.clear();
              });
              
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Refreshing...', style: TextStyle(decoration: TextDecoration.none, fontSize: 16, color: Colors.black, fontWeight: FontWeight.normal)),
                      ],
                    ),
                  ),
                ),
              );

              Future.delayed(const Duration(seconds: 1), () {
                if (!context.mounted) return;
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              });
            },
            icon: const Icon(Icons.refresh, color: AppColors.onSurfaceVariant),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAVinAsXQFdvQX9XHJeL0VfoMBVKCe9puTo008zB9XnFJJ28n58kyqEi_E9X0eHUN9V03x9qvGy33OyQU4yMuJSaJ0aggTAqLtmyv6wmn-q7zAva_CftED6dMADcnOZP2VtAVbsYYKaKBuMKfpytRi-5CKKEWqVJvfZfv22XZzG5DWPgXTcCevDaqBiPlU0hSw123QMMrYiQf0jaXSNAQ17RLVxYUmovGVdbTjDCeASbMty5xLxYht3DiJQwe0RcuE9rRCz0NNhGG8'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.black.withValues(alpha: 0.05), height: 1),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          setState(() {
            _searchQuery = '';
            _selectedFilter = 'Today';
            _searchController.clear();
          });
        },
        child: Column(
          children: [
            // Search and Filters
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search patient or token...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    fillColor: AppColors.inputBackground,
                    suffixIcon: _searchQuery.isNotEmpty 
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  ),
                ),
                const SizedBox(height: 24),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', _selectedFilter == 'All', context),
                      const SizedBox(width: 8),
                      _buildFilterChip('Today', _selectedFilter == 'Today', context),
                      const SizedBox(width: 8),
                      _buildFilterChip('This Week', _selectedFilter == 'This Week', context),
                      const SizedBox(width: 8),
                      _buildFilterChip('Completed', _selectedFilter == 'Completed', context),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                Text(
                  _searchQuery.isEmpty ? '$_selectedFilter\'s List' : 'Search Results', 
                  style: textTheme.headlineMedium?.copyWith(fontSize: 18)
                ),
                const SizedBox(height: 16),
                ..._filteredAppointments.map((appt) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildAppointmentCard(
                    context,
                    appt['token'],
                    appt['name'],
                    appt['status'],
                    appt['date'],
                    appt['time'],
                    appt['color'],
                    textTheme,
                    showCheckIn: appt['showCheckIn'] ?? false,
                    statusColor: appt['statusColor'],
                    footer: appt['footer'],
                    opacity: appt['opacity'] ?? 1.0,
                  ),
                )),
                if (_filteredAppointments.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.search_off, size: 64, color: AppColors.outline),
                          const SizedBox(height: 16),
                          Text('No results found', style: textTheme.bodyLarge),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.outline,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: textTheme.labelLarge?.copyWith(fontSize: 10),
        unselectedLabelStyle: textTheme.labelLarge?.copyWith(fontSize: 10),
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/clinicos-overview');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/appointments');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/book-appointment');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'OVERVIEW'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'APPOINTMENTS'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'BOOK APPOINTMENT'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.inputBackground,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(
    BuildContext context,
    String token,
    String name,
    String status,
    String date,
    String time,
    Color accentColor,
    TextTheme textTheme, {
    bool showCheckIn = false,
    Color? statusColor,
    String? footer,
    double opacity = 1.0,
  }) {
    return Opacity(
      opacity: opacity,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(token, style: textTheme.labelLarge),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: (statusColor ?? AppColors.primaryContainer).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: textTheme.labelSmall?.copyWith(
                                color: statusColor ?? AppColors.primaryContainer,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(name, style: textTheme.headlineMedium?.copyWith(fontSize: 18)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: AppColors.outline),
                          const SizedBox(width: 8),
                          Text(date, style: textTheme.bodyMedium),
                          const SizedBox(width: 16),
                          Icon(Icons.access_time, size: 16, color: AppColors.outline),
                          const SizedBox(width: 8),
                          Text(time, style: textTheme.bodyMedium),
                        ],
                      ),
                      if (showCheckIn) ...[
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Checking in $name...'),
                                      backgroundColor: AppColors.primaryContainer,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryContainer,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('CHECK IN'),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward, size: 16),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.inputBackground,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.more_vert, color: AppColors.primaryContainer),
                            ),
                          ],
                        ),
                      ],
                      if (footer != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.withValues(alpha: 0.1)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, size: 14, color: Colors.green),
                              const SizedBox(width: 8),
                              Text(footer, style: textTheme.bodySmall?.copyWith(color: Colors.green)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
