import 'package:flutter/material.dart';
import '../theme.dart';
import 'package:intl/intl.dart';
import '../services/appointment_api.dart';
import 'dart:async';
import '../services/user_session.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  String _selectedFilter = 'Today';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<Map<String, dynamic>> _allAppointments = [];
  bool _isLoading = true;
  int _currentPage = 1;
  int _lastPage = 1;

  @override
  void initState() {
    super.initState();
    if (!UserSession.isLoggedIn || UserSession.userRole != 'receptionist') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/clinicos-overview');
      });
      return;
    }
    _fetchAppointments();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
      });
      _fetchAppointments(page: 1);
    });
  }

  Future<void> _fetchAppointments({int page = 1}) async {
    setState(() {
      _isLoading = true;
      _currentPage = page;
    });
    try {
      String? dateRange;
      String? status;
      
      if (_selectedFilter == 'All') {
        dateRange = 'all';
      } else if (_selectedFilter == 'Today') {
        dateRange = 'today';
      } else if (_selectedFilter == 'This Week') {
        dateRange = 'week';
      } else if (_selectedFilter == 'Completed') {
        dateRange = 'all';
        status = 'completed';
      }

      final response = await AppointmentApi().getAppointmentHistory(
        page: page,
        dateRange: dateRange,
        status: status,
        search: _searchQuery,
      );
      if (response != null && response['status'] == true) {
        final List<dynamic> list = response['data']?['appointments']?['list'] ?? [];
        final pagination = response['data']?['appointments']?['pagination'];
        
        setState(() {
          if (pagination != null) {
            _lastPage = pagination['last_page'] ?? 1;
            _currentPage = pagination['current_page'] ?? 1;
          }
          _allAppointments = list.map((item) {
            final patientName = item['patient']?['name'] ?? 'Unknown';
            final patientPhone = item['patient']?['phone'] ?? 'N/A';
            final doctorName = item['doctor']?['name'] ?? 'Not Assigned';
            final statusStr = item['status']?.toString().toLowerCase() ?? 'unknown';
            final dateStr = item['appointment_date'] ?? '';
            
            // Map status to color
            Color bgColor = AppColors.primaryContainer.withValues(alpha: 0.1);
            Color statusColor = AppColors.primary;
            String displayStatus = 'Upcoming';
            
            if (statusStr == 'completed') {
               bgColor = const Color(0xFFE2E8F0);
               statusColor = Colors.green;
               displayStatus = 'Completed';
            } else if (statusStr == 'waitlist') {
               bgColor = Colors.amber.withValues(alpha: 0.2);
               statusColor = Colors.orange[700]!;
               displayStatus = 'Waitlist';
            } else if (statusStr == 'cancelled' || statusStr == 'no show') {
               bgColor = AppColors.error.withValues(alpha: 0.1);
               statusColor = AppColors.error;
               displayStatus = 'No Show';
            } else {
               displayStatus = statusStr.isNotEmpty ? statusStr[0].toUpperCase() + statusStr.substring(1) : 'Pending';
               bgColor = AppColors.primaryContainer.withValues(alpha: 0.2);
               statusColor = AppColors.primary;
            }

            // Format date safely
            String formattedDate = dateStr;
            try {
              if (dateStr.isNotEmpty) {
                final dt = DateTime.parse(dateStr);
                formattedDate = DateFormat('MMM dd, yyyy').format(dt);
              }
            } catch (_) {}
            
            return {
              'token': 'TOKEN #${item['token']}',
              'name': patientName,
              'phone': patientPhone,
              'doctor': doctorName,
              'status': displayStatus,
              'date': formattedDate,
              'time': '--:--', // API doesn't provide time yet
              'color': bgColor,
              'statusColor': statusColor,
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error fetching appointments: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredAppointments {
    return _allAppointments;
  }

  @override
  Widget build(BuildContext context) {
    if (!UserSession.isLoggedIn || UserSession.userRole != 'receptionist') {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
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
              _fetchAppointments(page: 1);
              
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
          setState(() {
            _searchQuery = '';
            _selectedFilter = 'Today';
            _searchController.clear();
          });
          await _fetchAppointments(page: 1);
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            // Search and Filters
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search patient or token...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    fillColor: AppColors.inputBackground,
                    suffixIcon: _searchController.text.isNotEmpty 
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
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
                    phone: appt['phone'],
                    doctor: appt['doctor'],
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
          if (_lastPage > 1)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: _currentPage > 1 ? () => _fetchAppointments(page: _currentPage - 1) : null,
                      icon: const Icon(Icons.chevron_left),
                      label: const Text('Prev'),
                    ),
                    Text('Page $_currentPage of $_lastPage', style: textTheme.labelLarge),
                    TextButton.icon(
                      onPressed: _currentPage < _lastPage ? () => _fetchAppointments(page: _currentPage + 1) : null,
                      icon: const Icon(Icons.chevron_right),
                      label: const Text('Next'),
                      iconAlignment: IconAlignment.end,
                    ),
                  ],
                ),
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
          if (index == 1) return;
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/receptionist-book-appointment');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'DASHBOARD'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), activeIcon: Icon(Icons.calendar_month), label: 'APPOINTMENTS'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), activeIcon: Icon(Icons.add_circle), label: 'BOOK APPOINTMENT'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_selectedFilter != label) {
          setState(() {
            _selectedFilter = label;
          });
          _fetchAppointments(page: 1);
        }
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
    String? phone,
    String? doctor,
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
                      if (phone != null && phone != 'N/A') ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.phone, size: 14, color: AppColors.outline),
                            const SizedBox(width: 6),
                            Text(phone, style: textTheme.bodyMedium?.copyWith(color: AppColors.outline)),
                          ],
                        ),
                      ],
                      if (doctor != null && doctor != 'Not Assigned') ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.medical_services_outlined, size: 14, color: AppColors.outline),
                            const SizedBox(width: 6),
                            Text(doctor, style: textTheme.bodyMedium?.copyWith(color: AppColors.outline)),
                          ],
                        ),
                      ],
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
