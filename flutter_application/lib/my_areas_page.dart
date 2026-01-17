import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'models/area_model.dart';
import 'services/areas_data.dart';
import 'edit_area_page.dart';

class MyAreasPage extends StatefulWidget {
  const MyAreasPage({super.key});

  @override
  State<MyAreasPage> createState() => _MyAreasPageState();
}

class _MyAreasPageState extends State<MyAreasPage> {
  List<AreaModel> areas = [];
  bool loading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAreas();
  }

  Future<void> _loadAreas() async {
    setState(() => loading = true);

    try {
      final data = await AreasData.getAllAreas();
      setState(() {
        areas = data;
        loading = false;
      });
    } catch (e) {
      debugPrint('Erreur chargement areas: $e');
      setState(() => loading = false);
    }
  }

  Future<void> _toggleArea(String areaId) async {
    debugPrint('[MyAreasPage] _toggleArea START - areaId: $areaId');
    
    try {
      debugPrint('[MyAreasPage] _toggleArea - Appel AreasData.toggleArea...');
      final success = await AreasData.toggleArea(areaId);
      debugPrint('[MyAreasPage] _toggleArea - Résultat: $success');
      
      if (success) {
        setState(() {
          // Comparer avec toString() pour gérer int vs String
          final index = areas.indexWhere((a) => a.id.toString() == areaId);
          debugPrint('[MyAreasPage] _toggleArea - Index trouvé: $index');
          if (index != -1) {
            final oldStatus = areas[index].isActive;
            areas[index] = areas[index].copyWith(
              isActive: !areas[index].isActive,
            );
            debugPrint('[MyAreasPage] _toggleArea - État changé: $oldStatus -> ${areas[index].isActive}');
            
            // SnackBar avec le nouvel état
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('AREA ${areas[index].isActive ? "activée" : "mise en pause"}'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        });
      } else {
        debugPrint('[MyAreasPage] _toggleArea - Échec (status != 200)');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Échec du changement d\'état'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('[MyAreasPage] _toggleArea ERROR: $e');
      debugPrint('[MyAreasPage] _toggleArea STACK: $stackTrace');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _deleteArea(String areaId) async {
    debugPrint('[MyAreasPage] _deleteArea START - areaId: $areaId');
    
    try {
      debugPrint('[MyAreasPage] _deleteArea - Appel AreasData.deleteArea...');
      final success = await AreasData.deleteArea(areaId);
      debugPrint('[MyAreasPage] _deleteArea - Résultat: $success');
      
      if (success) {
        setState(() {
          // Comparer avec toString() pour gérer int vs String
          areas.removeWhere((a) => a.id.toString() == areaId);
          debugPrint('[MyAreasPage] _deleteArea - AREA supprimée de la liste');
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AREA supprimée avec succès'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        debugPrint('[MyAreasPage] _deleteArea - Échec (status != 200)');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Échec de la suppression'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('[MyAreasPage] _deleteArea ERROR: $e');
      debugPrint('[MyAreasPage] _deleteArea STACK: $stackTrace');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showAreaOptions(AreaModel area) {
    debugPrint('[MyAreasPage] _showAreaOptions - Area: ${area.id} - ${area.name}');
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(
                  area.isActive ? Icons.pause_circle : Icons.play_circle,
                  color: const Color(0xFF4F46E5),
                ),
                title: Text(area.isActive ? 'Pause' : 'Activate'),
                onTap: () {
                  Navigator.pop(context);
                  _toggleArea(area.id.toString());
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFF4F46E5)),
                title: const Text('Edit'),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditAreaPage(area: area),
                    ),
                  );
                  // Recharger la liste si l'AREA a été modifiée
                  if (result == true) {
                    _loadAreas();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Color(0xFFEF4444)),
                title: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(area);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(AreaModel area) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete AREA'),
        content: Text('Are you sure you want to delete "${area.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteArea(area.id.toString());
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  List<AreaModel> get filteredAreas {
    if (searchQuery.isEmpty) return areas;
    return areas.where((area) {
      return area.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          area.triggerService.toLowerCase().contains(searchQuery.toLowerCase()) ||
          area.actionService.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          // Search bar
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search AREAs...',
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Areas list
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : filteredAreas.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.radar,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              searchQuery.isEmpty
                                  ? 'No AREAs yet'
                                  : 'No matching AREAs',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              searchQuery.isEmpty
                                  ? 'Create your first automation'
                                  : 'Try a different search term',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadAreas,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredAreas.length,
                          itemBuilder: (context, index) {
                            final area = filteredAreas[index];
                            return TweenAnimationBuilder<double>(
                              duration: Duration(milliseconds: 400 + (index * 100)),
                              tween: Tween(begin: 0.0, end: 1.0),
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(30 * (1 - value), 0),
                                    child: child,
                                  ),
                                );
                              },
                              child: _buildAreaCard(area),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaCard(AreaModel area) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showAreaOptions(area),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        area.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: area.isActive
                            ? const Color(0xFF10B981).withOpacity(0.1)
                            : const Color(0xFF6B7280).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: area.isActive
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF6B7280),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            area.isActive ? 'Active' : 'Paused',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: area.isActive
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Trigger
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.flash_on,
                        size: 20,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            area.triggerService,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            area.triggerName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Arrow
                Center(
                  child: Icon(
                    Icons.arrow_downward,
                    size: 20,
                    color: Colors.grey.shade400,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Action
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.bolt,
                        size: 20,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            area.actionService,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            area.actionName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}