import 'package:flutter/material.dart';
import '../theme.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu, color: AppColors.onSurfaceVariant),
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
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: AppColors.onSurfaceVariant),
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
          child: Container(color: Colors.black.withOpacity(0.05), height: 1),
        ),
      ),
      body: Column(
        children: [
          // Search and Filters
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search patient or token...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    fillColor: AppColors.inputBackground,
                  ),
                ),
                const SizedBox(height: 24),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', false, context),
                      const SizedBox(width: 8),
                      _buildFilterChip('Today', true, context),
                      const SizedBox(width: 8),
                      _buildFilterChip('This Week', false, context),
                      const SizedBox(width: 8),
                      _buildFilterChip('Completed', false, context),
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
                Text('Today\'s List', style: textTheme.headlineMedium?.copyWith(fontSize: 18)),
                const SizedBox(height: 16),
                _buildAppointmentCard(
                  context,
                  'TOKEN #104',
                  'Eleanor Penhaligon',
                  'Upcoming',
                  'Oct 24, 2023',
                  '10:30 AM',
                  AppColors.primaryContainer,
                  textTheme,
                  showCheckIn: true,
                ),
                const SizedBox(height: 16),
                _buildAppointmentCard(
                  context,
                  'TOKEN #102',
                  'Arthur Sterling',
                  'Completed',
                  'Oct 24, 2023',
                  '09:15 AM',
                  const Color(0xFFE2E8F0),
                  textTheme,
                  statusColor: Colors.green,
                ),
                const SizedBox(height: 16),
                _buildAppointmentCard(
                  context,
                  'TOKEN #105',
                  'Clara Abernathy',
                  'Waitlist',
                  'Oct 24, 2023',
                  '11:00 AM',
                  Colors.amber,
                  textTheme,
                  statusColor: Colors.amber[700],
                  footer: 'Patient has arrived',
                ),
                const SizedBox(height: 16),
                _buildAppointmentCard(
                  context,
                  'TOKEN #101',
                  'Julian Vance',
                  'No Show',
                  'Oct 24, 2023',
                  '08:45 AM',
                  AppColors.error,
                  textTheme,
                  statusColor: AppColors.error,
                  opacity: 0.6,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primaryContainer,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryContainer,
        unselectedItemColor: AppColors.outline,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/book-appointment');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'OVERVIEW'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'HISTORY'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'BOOK APPT'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? AppColors.primaryContainer : AppColors.inputBackground,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: selected ? Colors.white : AppColors.onSurfaceVariant,
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
    Color borderColor,
    TextTheme textTheme, {
    Color? statusColor,
    bool showCheckIn = false,
    String? footer,
    double opacity = 1.0,
  }) {
    return Opacity(
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: borderColor, width: 4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(token, style: textTheme.labelLarge?.copyWith(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(name, style: textTheme.headlineMedium?.copyWith(fontSize: 18)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: (statusColor ?? AppColors.primaryContainer).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: textTheme.labelLarge?.copyWith(
                      color: statusColor ?? AppColors.primaryContainer,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: AppColors.outline),
                const SizedBox(width: 8),
                Text(date, style: textTheme.bodyMedium),
                const SizedBox(width: 24),
                Icon(Icons.schedule, size: 14, color: AppColors.outline),
                const SizedBox(width: 8),
                Text(time, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            if (showCheckIn) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
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
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert, color: AppColors.primaryContainer),
                    ),
                  ),
                ],
              ),
            ],
            if (footer != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 14, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(footer, style: textTheme.bodyMedium?.copyWith(color: Colors.grey, fontStyle: FontStyle.italic)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
