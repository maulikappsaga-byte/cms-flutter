import 'package:flutter/material.dart';
import '../theme.dart';

class PatientFilesScreen extends StatefulWidget {
  const PatientFilesScreen({super.key});

  @override
  State<PatientFilesScreen> createState() => _PatientFilesScreenState();
}

class _PatientFilesScreenState extends State<PatientFilesScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _allPatients = [
    {
      'name': 'Sarah Jenkins',
      'id': 'ID: P-1024',
      'lastVisit': 'Last visit: Today, 10:30 AM',
    },
    {
      'name': 'John Doe',
      'id': 'ID: P-1025',
      'lastVisit': 'Last visit: Oct 28, 2023',
    },
    {
      'name': 'Alice Smith',
      'id': 'ID: P-1026',
      'lastVisit': 'Last visit: Oct 25, 2023',
    },
    {
      'name': 'Michael Brown',
      'id': 'ID: P-1027',
      'lastVisit': 'Last visit: Oct 22, 2023',
    },
    {
      'name': 'Emma Wilson',
      'id': 'ID: P-1028',
      'lastVisit': 'Last visit: Oct 20, 2023',
    },
  ];

  List<Map<String, String>> get _filteredPatients {
    if (_searchQuery.isEmpty) return _allPatients;
    return _allPatients.where((patient) {
      final name = patient['name']!.toLowerCase();
      final id = patient['id']!.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || id.contains(query);
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
          'Patient Files',
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
                setState(() {
                  _searchQuery = '';
                  _searchController.clear();
                });
              });
            },
            icon: const Icon(Icons.refresh, color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search patients...',
                prefixIcon: const Icon(Icons.search),
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
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                ..._filteredPatients.map((patient) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildPatientCard(
                    context,
                    patient['name']!,
                    patient['id']!,
                    patient['lastVisit']!,
                    textTheme,
                  ),
                )),
                if (_filteredPatients.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Column(
                        children: [
                          const Icon(Icons.search_off, size: 64, color: AppColors.outline),
                          const SizedBox(height: 16),
                          Text('No patients found', style: textTheme.bodyLarge),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(BuildContext context, String name, String id, String lastVisit, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.person, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text(id, style: textTheme.labelLarge),
                const SizedBox(height: 4),
                Text(lastVisit, style: textTheme.bodyMedium?.copyWith(fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.outline),
        ],
      ),
    );
  }
}
