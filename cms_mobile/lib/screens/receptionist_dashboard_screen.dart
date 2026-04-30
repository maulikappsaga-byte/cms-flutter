import 'package:flutter/material.dart';
import '../theme.dart';

class ReceptionistDashboardScreen extends StatelessWidget {
  const ReceptionistDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryContainer.withOpacity(0.2), width: 2),
                image: const DecorationImage(
                  image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBj34gfl1ao1p6j0aJinT66BSaqMfy7rFuycWGFzw8bKZ00oApXUIE15XhRpO-pJUPGGw1_xPe9f5bpzOhjE54umLrSOlJ8DKqfgxTiwkYbF8MOMjyGLoR_5yQRBgXb3AZjxOonDW5yDEGKLyWOW2m_ZdTzS-Y2KVgsTsiCSP6xc_qaWwFyusYC8qXfZBA3lgd0a6HzY0YUyDUoc1vPvNI3dVBD3OlEH2pwFwzQ59wX-inhQTtc9JQCwnI6-pfubJ9KGSAWmR66E6E'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Reception Desk',
              style: textTheme.headlineMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
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
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              });
            },
            icon: const Icon(Icons.refresh, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.black.withOpacity(0.05), height: 1),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Simulate a network delay or data fetch
          await Future.delayed(const Duration(seconds: 1));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Dashboard updated'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // Ensure it's scrollable for RefreshIndicator
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Live Queue Manager
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: const Border(
                  left: BorderSide(color: AppColors.primary, width: 4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Live Queue Manager', style: textTheme.headlineMedium?.copyWith(fontSize: 20)),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 4),
                              Text('LIVE', style: textTheme.labelLarge?.copyWith(color: AppColors.primary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('CURRENT NEXT', style: textTheme.labelLarge),
                              const SizedBox(height: 4),
                              Text('01 Dipakabhai sir', style: textTheme.headlineMedium?.copyWith(fontSize: 18, color: AppColors.primary)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('WAIT TIME', style: textTheme.labelLarge),
                              const SizedBox(height: 4),
                              Text('04:20', style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/call-next');
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('CALL NEXT PATIENT'),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Today's Performance
            Text('TODAY\'S PERFORMANCE', style: textTheme.labelLarge?.copyWith(letterSpacing: 2)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(context, 'COMPLETED', '24', '+12%', textTheme),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(context, 'PENDING', '08', 'L-04', textTheme),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TOTAL APPOINTMENTS', style: textTheme.labelLarge),
                      Text('32', style: textTheme.headlineLarge?.copyWith(color: AppColors.onSurface)),
                    ],
                  ),
                  const SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      value: 0.75,
                      strokeWidth: 4,
                      backgroundColor: AppColors.background,
                      color: AppColors.primaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Administrative Tools
            Text('ADMINISTRATIVE TOOLS', style: textTheme.labelLarge?.copyWith(letterSpacing: 2)),
            const SizedBox(height: 12),
            _buildActionButton(context, Icons.add_box, 'Book New Appointment', textTheme, onTap: () {
              Navigator.pushNamed(context, '/book-appointment');
            }),
            const SizedBox(height: 12),
            _buildActionButton(context, Icons.folder_shared, 'Access Patient Files', textTheme, onTap: () {
              Navigator.pushNamed(context, '/patient-files');
            }),
            const SizedBox(height: 32),
            // Today's Appointments
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TODAY\'S APPOINTMENTS', style: textTheme.labelLarge?.copyWith(letterSpacing: 2)),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/appointments');
                  },
                  child: Text('View All History', style: textTheme.labelLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            _buildAppointmentItem(context, '09:00 AM', 'Eleanor Penhaligon', 'Check-up', 'Token #104', textTheme),
            const SizedBox(height: 12),
            _buildAppointmentItem(context, '10:30 AM', 'Arthur Sterling', 'Follow-up', 'Token #102', textTheme),
            const SizedBox(height: 12),
            _buildAppointmentItem(context, '11:45 AM', 'Clara Abernathy', 'Consultation', 'Token #105', textTheme),
            const SizedBox(height: 24),
            // Shift Oversight
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.onBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Shift Oversight', style: textTheme.headlineMedium?.copyWith(color: Colors.white, fontSize: 18)),
                      Text('DR. MORRISON', style: textTheme.labelLarge?.copyWith(color: Colors.white.withOpacity(0.6))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildAvatar('https://lh3.googleusercontent.com/aida-public/AB6AXuANihBFb2zH9-0P0joahzrCMGAJo5X4yX1mG6T0s8kcOi6jPUqDiI2-zrMQbq1J9IN4FiJGDM-3HOfCYQkXJT0-x0l2YNCbOuaziKFQJKi6O7B78kPTE_Fq3i5NbRYn-Fm2pFQRmRLbZb0CdqON8eCOckX3TkNAoCU8Oa4Sk1vfzZTcEJ8GqGGeCrKfffvFTvFlBicNVt-YVPl49N98MBoWJG1YkbdMBZKTmvqbkrqFHmBHcJbbC_CKVf9ZpXUNV-khMvLo1k0IRkA'),
                      const SizedBox(width: 8),
                      _buildAvatar('https://lh3.googleusercontent.com/aida-public/AB6AXuCpNdi0pb4TV0QSzSO3hJle5_izKyhBVEhNIBJfIH6lWOWm2XUtwkeR3MTrUZetUtHdUnlxe7-QDOXmQO7AwDctIGViS_mz9jPTBwCApoW3Yd0_oIG2VeLmq6vv_IPomLt-VgsIBTSGsd6Gi8t5JeQVP6jHsOJ2Vs__chyFfPAg79m5iDpAPfsGVeo1v-kcuo0L576bYJBITJGECkxwZrpk17TuiQiM7WugaNbRsaXFmwyT_YcymiSrWOAMbI7m4Z_rJ1nAvZ76tDo'),
                      const SizedBox(width: 8),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.outline.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(child: Text('+4', style: TextStyle(color: Colors.white, fontSize: 12))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'All examination rooms currently at 85% capacity. Expected peak at 14:00.',
                    style: textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.outline,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: textTheme.labelLarge?.copyWith(fontSize: 10),
        unselectedLabelStyle: textTheme.labelLarge?.copyWith(fontSize: 10),
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/appointments');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/patient-files');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.format_list_numbered), label: 'QUEUE'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'SCHEDULE'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'PATIENTS'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'ADMIN'),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, String sub, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: textTheme.labelLarge),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: textTheme.headlineLarge?.copyWith(color: AppColors.onSurface)),
              Text(sub, style: textTheme.labelLarge?.copyWith(color: sub.startsWith('+') ? AppColors.primary : AppColors.outline)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, TextTheme textTheme, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
                ],
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
            const Icon(Icons.chevron_right, color: AppColors.outline),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String url) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.onBackground, width: 2),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildAppointmentItem(BuildContext context, String time, String name, String service, String token, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(time, style: textTheme.labelLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text(service, style: textTheme.labelLarge),
              ],
            ),
          ),
          Text(token, style: textTheme.labelLarge?.copyWith(color: AppColors.outline)),
        ],
      ),
    );
  }
}
