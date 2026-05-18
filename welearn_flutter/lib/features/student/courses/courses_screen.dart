import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/models/course_model.dart';
import '../../../shared/widgets/course_card.dart';

final _coursesProvider = FutureProvider.family<List<CourseModel>, Map<String, dynamic>>(
  (ref, params) async {
    final client = ref.read(apiClientProvider);
    final res = await client.get(ApiEndpoints.courses, queryParameters: params);
    final list = (res.data['data'] ?? res.data['courses'] ?? []) as List;
    return list.map((c) => CourseModel.fromJson(c as Map<String, dynamic>)).toList();
  },
);

final _categoriesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.courseCategories);
  final list = (res.data['data'] ?? res.data['categories'] ?? []) as List;
  return list.cast<Map<String, dynamic>>();
});

class StudentCoursesScreen extends ConsumerStatefulWidget {
  const StudentCoursesScreen({super.key});

  @override
  ConsumerState<StudentCoursesScreen> createState() =>
      _StudentCoursesScreenState();
}

class _StudentCoursesScreenState
    extends ConsumerState<StudentCoursesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchCtrl = TextEditingController();
  String? _selectedCategory;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(_categoriesProvider);
    final params = <String, dynamic>{
      'isPublished': 'true',
      if (_selectedCategory != null) 'category': _selectedCategory,
      if (_search.isNotEmpty) 'search': _search,
    };
    final courses = ref.watch(_coursesProvider(params));
    final myEnrollments = ref.watch(
      _coursesProvider({'enrolled': 'true'}),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Courses'),
            Tab(text: 'My Courses'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search courses...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _search = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) =>
                  setState(() => _search = v),
            ),
          ),
          categories.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (cats) => SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: cats.length + 1,
                itemBuilder: (_, i) {
                  if (i == 0) {
                    return _CategoryChip(
                      label: 'All',
                      selected: _selectedCategory == null,
                      onTap: () => setState(() => _selectedCategory = null),
                    );
                  }
                  final cat = cats[i - 1];
                  return _CategoryChip(
                    label: cat['name'] as String? ?? '',
                    selected: _selectedCategory == cat['_id'],
                    onTap: () => setState(
                        () => _selectedCategory = cat['_id'] as String?),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCourseGrid(courses),
                _buildCourseGrid(myEnrollments),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseGrid(AsyncValue<List<CourseModel>> async) {
    return async.when(
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (courses) => courses.isEmpty
          ? const Center(child: Text('No courses found'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: courses.length,
              itemBuilder: (_, i) => CourseCard(course: courses[i]),
            ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip(
      {required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
