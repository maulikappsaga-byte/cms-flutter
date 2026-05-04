import 'package:flutter/material.dart';
import '../theme.dart';

class BookAppointmentAppScreen extends StatelessWidget {
  const BookAppointmentAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.medical_services, color: AppColors.primaryContainer),
            const SizedBox(width: 8),
            Text(
              'ClinicFlow',
              style: textTheme.headlineMedium?.copyWith(
                fontSize: 20,
                color: AppColors.primaryContainer,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.inputBackground, width: 1),
              image: const DecorationImage(
                image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCPOkHnZXZjmDG-xz1UUa-9W-SGAknx6t_3GVH44tJuAsC8EpCVliuRi-ArMV7TJ9ZBzEj7OByqJitxOlIi2qA155h7bXoPkkt9FwS9dWfU1cD78QyMW-_tvjHfbwyHy_oFyyO-djvQECE3k5mHzpdKHmZ5mXled03it8a5RJyKnk3myEh9SqZoJvg5fHRYzHymZaNcpVwg1XsloXc5xghK_RqEzNSwu0ioaOyBoKYgxyiYbwSn2Ad3wbQbVLw5Wcdx_1cW7b3Ts5E'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Book New Appointment',
                textAlign: TextAlign.center,
                style: textTheme.headlineLarge?.copyWith(
                  fontSize: 32,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Please provide your details to secure your clinical slot.',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(color: AppColors.secondary),
              ),
            ),
            const SizedBox(height: 48),
            // Form Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: const Border(left: BorderSide(color: AppColors.primary, width: 4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('FULL NAME', style: textTheme.labelLarge),
                  const SizedBox(height: 4),
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person, color: AppColors.primaryContainer),
                      hintText: 'e.g. Dr. Jane Smith',
                      fillColor: AppColors.inputBackground,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('MOBILE NO.', style: textTheme.labelLarge),
                  const SizedBox(height: 4),
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.phone, color: AppColors.primaryContainer),
                      hintText: '+1 (555) 000-0000',
                      fillColor: AppColors.inputBackground,
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Confirm & Book Appointment'),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'REVIEW CLINIC POLICIES',
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            // Next Available
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.inputBackground.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.calendar_today, color: AppColors.primary),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('NEXT AVAILABLE', style: textTheme.labelLarge),
                          Text('Today, 2:30 PM', style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('ACTIVE', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Decorative
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCAWdgfEmlsP1IIkiU4YDdPYCXv9ccQeVlzKuZYpMjhayDWFYq8SwfUvUi2sABCR8SmgvfTAyBV4m6dc-j5O8wMaPXS2Z8r0FIXzRKU7Ddh0emeQ6iQx0-xhk2baa0g23ATsYnISrmu4-XNDNOH8kyePzqGyqQvsqYgmVx07QKgHQYnWmSxUVuWxHOf6xceym03L91a-LS6LwHT4n08C50WdOzW8DGg_Cf5yAx7SC5tqAkiFejRvoX4hm5QImHlcQVuWpiQDpx6gKk',
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.background.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primaryContainer,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
