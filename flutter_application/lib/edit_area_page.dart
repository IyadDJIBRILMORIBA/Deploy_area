import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'models/area_model.dart';
import 'services/areas_data.dart';

class EditAreaPage extends StatefulWidget {
  final AreaModel area;

  const EditAreaPage({super.key, required this.area});

  @override
  State<EditAreaPage> createState() => _EditAreaPageState();
}

class _EditAreaPageState extends State<EditAreaPage> {
  late TextEditingController _nameController;
  late bool _isActive;
  late Map<String, TextEditingController> _triggerControllers;
  late Map<String, TextEditingController> _actionControllers;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.area.name);
    _isActive = widget.area.isActive;
    
    // Créer des contrôleurs pour chaque paramètre du trigger
    _triggerControllers = {};
    widget.area.triggerParams.forEach((key, value) {
      _triggerControllers[key] = TextEditingController(text: value?.toString() ?? '');
    });
    
    // Créer des contrôleurs pour chaque paramètre de l'action
    _actionControllers = {};
    widget.area.actionParams.forEach((key, value) {
      _actionControllers[key] = TextEditingController(text: value?.toString() ?? '');
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _triggerControllers.values.forEach((controller) => controller.dispose());
    _actionControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le nom ne peut pas être vide'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      debugPrint('[EditAreaPage] Mise à jour AREA ${widget.area.id}...');
      
      // Construire les maps de paramètres depuis les contrôleurs
      final triggerParams = <String, dynamic>{};
      _triggerControllers.forEach((key, controller) {
        if (controller.text.isNotEmpty) {
          triggerParams[key] = controller.text;
        }
      });
      
      final actionParams = <String, dynamic>{};
      _actionControllers.forEach((key, controller) {
        if (controller.text.isNotEmpty) {
          actionParams[key] = controller.text;
        }
      });
      
      await AreasData.updateArea(
        areaId: widget.area.id.toString(),
        name: _nameController.text.trim(),
        isActive: _isActive,
        triggerParams: triggerParams.isNotEmpty ? triggerParams : null,
        actionParams: actionParams.isNotEmpty ? actionParams : null,
      );

      if (mounted) {
        debugPrint('[EditAreaPage] AREA mise à jour avec succès');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AREA mise à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Retourner true pour indiquer la mise à jour
      }
    } catch (e) {
      debugPrint('[EditAreaPage] Erreur: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Modifier AREA',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveChanges,
              child: const Text(
                'Enregistrer',
                style: TextStyle(
                  color: Color(0xFF4F46E5),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nom de l'AREA
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nom de l\'AREA',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Ex: Notification email',
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // État actif/inactif
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'État de l\'AREA',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isActive ? 'Active' : 'En pause',
                            style: TextStyle(
                              fontSize: 14,
                              color: _isActive
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isActive,
                      onChanged: (value) {
                        setState(() => _isActive = value);
                      },
                      activeColor: const Color(0xFF4F46E5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Trigger
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        const Text(
                          'Déclencheur',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.area.triggerService,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.area.triggerName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_triggerControllers.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Paramètres modifiables:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._triggerControllers.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatParamLabel(entry.key),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: entry.value,
                                decoration: InputDecoration(
                                  hintText: 'Entrez ${_formatParamLabel(entry.key).toLowerCase()}',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ] else ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Aucun paramètre configurable',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Action
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        const Text(
                          'Action',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.area.actionService,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.area.actionName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_actionControllers.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Paramètres modifiables:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._actionControllers.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatParamLabel(entry.key),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: entry.value,
                                maxLines: entry.key == 'body' ? 3 : 1,
                                decoration: InputDecoration(
                                  hintText: 'Entrez ${_formatParamLabel(entry.key).toLowerCase()}',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ] else ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Aucun paramètre configurable',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Note informative
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF86EFAC),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Color(0xFF16A34A),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Vous pouvez modifier tous les paramètres de cette AREA.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatParamLabel(String key) {
    // Capitaliser et remplacer underscores
    final words = key.split('_');
    return words.map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }
}
