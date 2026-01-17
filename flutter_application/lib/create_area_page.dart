import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'models/trigger_action_model.dart';
import 'services/create_area_data.dart';
import 'services/areas_data.dart';
import 'configure_trigger_page.dart';
import 'configure_action_page.dart';

class CreateAreaPage extends StatefulWidget {
  const CreateAreaPage({super.key});

  @override
  State<CreateAreaPage> createState() => _CreateAreaPageState();
}

class _CreateAreaPageState extends State<CreateAreaPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String? selectedTriggerId;
  String? selectedActionId;
  TriggerActionModel? selectedTrigger;
  TriggerActionModel? selectedAction;
  Map<String, dynamic> triggerParams = {};
  Map<String, dynamic> actionParams = {};
  
  List<TriggerActionModel> triggers = [];
  List<TriggerActionModel> actions = [];
  bool loading = true;
  
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
    _loadData();
    
    // Listener pour mettre à jour le bouton quand on tape le nom
    _nameController.addListener(() {
      setState(() {});
    });
  }

  Future<void> _loadData() async {
    setState(() => loading = true);
    try {
      final results = await Future.wait([
        CreateAreaData.getAvailableTriggers(),
        CreateAreaData.getAvailableActions(),
      ]);
      setState(() {
        triggers = results[0];
        actions = results[1];
        loading = false;
      });
    } catch (e) {
      debugPrint('Error loading triggers/actions: $e');
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create AREA',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: loading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Nom de l'AREA en haut
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 600),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, -20 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Name your automation',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildTextField(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Carré TRIGGER (en haut)
                      _buildBigCard(
                        context: context,
                        isDark: isDark,
                        title: 'When this happens',
                        icon: Icons.flash_on_rounded,
                        color: const Color(0xFF10B981),
                        selectedItem: selectedTrigger,
                        onTap: () => _showSelectionSheet(context, true),
                        delay: 0,
                      ),

                      const SizedBox(height: 32),

                      // Flèche animée
                      _buildAnimatedArrow(),

                      const SizedBox(height: 32),

                      // Carré ACTION (en bas)
                      _buildBigCard(
                        context: context,
                        isDark: isDark,
                        title: 'Do this',
                        icon: Icons.bolt_rounded,
                        color: const Color(0xFF6366F1),
                        selectedItem: selectedAction,
                        onTap: () => _showSelectionSheet(context, false),
                        delay: 200,
                      ),

                      const SizedBox(height: 32),

                      // Bouton Create
                      _buildCreateButton(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildBigCard({
    required BuildContext context,
    required bool isDark,
    required String title,
    required IconData icon,
    required Color color,
    required TriggerActionModel? selectedItem,
    required VoidCallback onTap,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.9 + (0.1 * value),
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            height: 180,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: selectedItem != null
                    ? [
                        color.withOpacity(isDark ? 0.3 : 0.15),
                        color.withOpacity(isDark ? 0.2 : 0.08),
                      ]
                    : [
                        Theme.of(context).colorScheme.surface,
                        Theme.of(context).colorScheme.surface,
                      ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: selectedItem != null ? color : Theme.of(context).dividerColor,
                width: selectedItem != null ? 2 : 1,
              ),
              boxShadow: selectedItem != null
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color, color.withOpacity(0.7)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                      size: 32,
                    ),
                  ],
                ),
                if (selectedItem != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withOpacity(0.2)
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selectedItem.icon,
                          color: color,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedItem.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                selectedItem.serviceName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                  )
                else
                  Text(
                    'Tap to select',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSelectionSheet(BuildContext context, bool isTrigger) {
    final items = isTrigger ? triggers : actions;
    final color = isTrigger ? const Color(0xFF10B981) : const Color(0xFF6366F1);
    final title = isTrigger ? 'Select Trigger' : 'Select Action';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
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
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isTrigger ? Icons.flash_on_rounded : Icons.bolt_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          Navigator.pop(context); // Fermer le modal
                          
                          // Ouvrir la page de configuration
                          Map<String, dynamic>? params;
                          if (isTrigger) {
                            params = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ConfigureTriggerPage(trigger: item),
                              ),
                            );
                            
                            if (params != null) {
                              setState(() {
                                selectedTrigger = item;
                                selectedTriggerId = item.id;
                                triggerParams = params!;
                              });
                            }
                          } else {
                            params = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ConfigureActionPage(action: item),
                              ),
                            );
                            
                            if (params != null) {
                              setState(() {
                                selectedAction = item;
                                selectedActionId = item.id;
                                actionParams = params!;
                              });
                            }
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  item.icon,
                                  color: color,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.serviceName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                    if (item.description.isNotEmpty)
                                      Text(
                                        item.description,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, int delay) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _nameController,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: 'e.g., Send email when new commit',
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          prefixIcon: Icon(
            Icons.label_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildAnimatedArrow() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 3),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Center(
          child: Transform.translate(
            offset: Offset(0, 15 * math.sin(value * math.pi * 2)),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_downward_rounded,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _nameController,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: 'e.g., Send email when new commit',
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          prefixIcon: Icon(
            Icons.label_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    final canCreate = _nameController.text.isNotEmpty &&
        selectedTrigger != null &&
        selectedAction != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1200),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.9 + (0.1 * value),
            child: child,
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: canCreate
              ? const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                )
              : null,
          color: canCreate ? null : (isDark ? Colors.transparent : Colors.white),
          border: canCreate
              ? null
              : Border.all(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  width: 2,
                ),
          boxShadow: canCreate
              ? [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: canCreate ? () => _createArea() : null,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: canCreate ? Colors.white : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Create AREA',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: canCreate ? Colors.white : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createArea() async {
    if (_nameController.text.isEmpty || selectedTrigger == null || selectedAction == null) {
      return;
    }

    try {
      // Créer l'AREA via l'API avec les paramètres configurés
      await AreasData.createArea(
        name: _nameController.text,
        triggerService: selectedTrigger!.serviceId,
        triggerAction: selectedTrigger!.id,
        triggerParams: triggerParams,
        actionService: selectedAction!.serviceId,
        actionReaction: selectedAction!.id,
        actionParams: actionParams,
      );

      if (!mounted) return;

      // Animation de succès
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'AREA Created!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your automation is now active',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.popUntil(context, (route) => route.isFirst); // Return to dashboard
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error creating area: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
