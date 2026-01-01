import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _ctrl = TextEditingController();
  String category = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF07243A), Color(0xFF0B4F6A)])),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                GlassCard(child: TextField(controller: _ctrl, decoration: InputDecoration(hintText: 'Search by keyword', prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GlassCard(child: DropdownButtonFormField<String>(
                        value: category,
                        items: ['All', 'Politics', 'Business', 'Tech'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) => setState(() => category = v ?? 'All'),
                        decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      )),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(onPressed: () {}, child: const Text('Filter')),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(child: Center(child: GlassCard(child: Center(child: Text('Search results (mock)', style: Theme.of(context).textTheme.bodyLarge)))))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
