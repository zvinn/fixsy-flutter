import 'package:flutter/material.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('العناوين المحفوظة'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 0, // Mock empty state
        itemBuilder: (context, index) {
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-address');
        },
        child: const Icon(Icons.add),
      ),
      bottomSheet: _buildEmptyState(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'لا توجد عناوين محفوظة',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'قم بإضافة عنوان جديد لتسهيل عملية الطلب',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
