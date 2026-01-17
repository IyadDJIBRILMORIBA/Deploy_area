import 'package:flutter/material.dart';
import 'models/trigger_action_model.dart';

class ConfigureTriggerPage extends StatefulWidget {
  final TriggerActionModel trigger;

  const ConfigureTriggerPage({super.key, required this.trigger});

  @override
  State<ConfigureTriggerPage> createState() => _ConfigureTriggerPageState();
}

class _ConfigureTriggerPageState extends State<ConfigureTriggerPage> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, dynamic> _params = {};
  String? _selectedInterval; // Pour le dropdown Timer

  @override
  void initState() {
    super.initState();
    // Initialiser les paramètres par défaut
    // TODO: Récupérer les paramètres depuis l'API du trigger
    _initializeDefaultParams();
  }

  void _initializeDefaultParams() {
    final serviceId = widget.trigger.serviceId.toLowerCase();
    final triggerId = widget.trigger.id;
    
    print('🔧 ConfigureTrigger: service=$serviceId, trigger=$triggerId');
    
    // Map numeric service IDs to names
    String serviceName = serviceId;
    if (serviceId == '1') serviceName = 'google';
    else if (serviceId == '2') serviceName = 'timer';
    else if (serviceId == '3') serviceName = 'github';
    else if (serviceId == '4') serviceName = 'discord';
    else if (serviceId == '5') serviceName = 'slack';
    else if (serviceId == '6') serviceName = 'twitch';
    else if (serviceId == '7') serviceName = 'weather';
    else if (serviceId == '8') serviceName = 'trello';
    
    // Initialize based on service and trigger
    if (serviceName == 'timer') {
      _selectedInterval = 'every_minute';
      _params['interval'] = 'every_minute';
    } else if (serviceName == 'google') {
      if (triggerId == 'new_email') {
        _controllers['from'] = TextEditingController();
        _controllers['subject'] = TextEditingController();
      } else if (triggerId == 'new_calendar_event') {
        _controllers['event_title'] = TextEditingController();
      }
    } else if (serviceName == 'github') {
      if (triggerId == 'new_issue' || triggerId == 'new_pull_request' || triggerId == 'push_event') {
        _controllers['repository'] = TextEditingController();
      }
    } else if (serviceName == 'discord') {
      if (triggerId == 'new_message') {
        _controllers['channel_id'] = TextEditingController();
      }
    } else if (serviceName == 'slack') {
      if (triggerId == 'new_message') {
        _controllers['channel'] = TextEditingController();
      }
    } else if (serviceName == 'twitch') {
      if (triggerId == 'stream_online') {
        _controllers['channel'] = TextEditingController();
      }
    } else if (serviceName == 'weather') {
      if (triggerId == 'weather_change') {
        _controllers['city'] = TextEditingController();
      }
    } else if (serviceName == 'trello') {
      if (triggerId == 'new_card') {
        _controllers['board_id'] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Color _getServiceColor() {
    switch (widget.trigger.serviceName.toLowerCase()) {
      case 'google':
      case 'gmail':
        return const Color(0xFFEA4335);
      case 'github':
        return const Color(0xFF24292E);
      case 'discord':
        return const Color(0xFF5865F2);
      case 'slack':
        return const Color(0xFF4A154B);
      case 'twitch':
        return const Color(0xFF9146FF);
      case 'weather':
        return const Color(0xFFFFA500);
      case 'trello':
        return const Color(0xFF0079BF);
      default:
        return const Color(0xFF4F46E5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final serviceColor = _getServiceColor();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Configure Trigger',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step indicator
                  _buildStepIndicator(1, 4),
                  
                  const SizedBox(height: 32),

                  // Trigger card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: serviceColor.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: serviceColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            widget.trigger.icon,
                            color: serviceColor,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.trigger.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.trigger.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Configuration fields based on service
                  ..._buildConfigurationFields(isDark, serviceColor),
                ],
              ),
            ),
          ),

          // Bottom buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Theme.of(context).dividerColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back_rounded, size: 20, color: Theme.of(context).colorScheme.onSurface),
                        const SizedBox(width: 8),
                        Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      // Récupérer les valeurs des contrôleurs
                      for (var entry in _controllers.entries) {
                        _params[entry.key] = entry.value.text;
                      }
                      // Pour Timer, l'intervalle est déjà dans _params
                      Navigator.pop(context, _params);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: serviceColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Next: Choose Action',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 20),
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

  List<Widget> _buildConfigurationFields(bool isDark, Color serviceColor) {
    final serviceId = widget.trigger.serviceId.toLowerCase();
    final triggerId = widget.trigger.id;
    
    // Map numeric service IDs to names
    String serviceName = serviceId;
    if (serviceId == '1') serviceName = 'google';
    else if (serviceId == '2') serviceName = 'timer';
    else if (serviceId == '3') serviceName = 'github';
    else if (serviceId == '4') serviceName = 'discord';
    else if (serviceId == '5') serviceName = 'slack';
    else if (serviceId == '6') serviceName = 'twitch';
    else if (serviceId == '7') serviceName = 'weather';
    else if (serviceId == '8') serviceName = 'trello';
    
    List<Widget> fields = [];
    
    // Timer
    if (serviceName == 'timer') {
      fields.addAll([
        Text(
          'Intervalle de temps',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        _buildTimerDropdown(isDark, serviceColor),
      ]);
    }
    // Google
    else if (serviceName == 'google') {
      if (triggerId == 'new_email') {
        fields.addAll([
          _buildSectionTitle('Filter Email'),
          const SizedBox(height: 16),
          _buildTextField('from', 'Sender Email', 'sender@example.com', isDark, serviceColor),
          const SizedBox(height: 16),
          _buildTextField('subject', 'Subject Contains', 'invoice, payment', isDark, serviceColor),
        ]);
      } else if (triggerId == 'new_calendar_event') {
        fields.addAll([
          _buildSectionTitle('Filter Calendar Event'),
          const SizedBox(height: 16),
          _buildTextField('event_title', 'Event Title Contains', 'meeting', isDark, serviceColor),
        ]);
      }
    }
    // GitHub
    else if (serviceName == 'github') {
      if (triggerId == 'new_issue' || triggerId == 'new_pull_request' || triggerId == 'push_event') {
        fields.addAll([
          _buildSectionTitle('GitHub Repository'),
          const SizedBox(height: 16),
          _buildTextField('repository', 'Repository', 'owner/repo-name', isDark, serviceColor),
        ]);
      }
    }
    // Discord
    else if (serviceName == 'discord') {
      if (triggerId == 'new_message') {
        fields.addAll([
          _buildSectionTitle('Discord Channel'),
          const SizedBox(height: 16),
          _buildTextField('channel_id', 'Channel ID', '123456789012345678', isDark, serviceColor),
        ]);
      }
    }
    // Slack
    else if (serviceName == 'slack') {
      if (triggerId == 'new_message') {
        fields.addAll([
          _buildSectionTitle('Slack Channel'),
          const SizedBox(height: 16),
          _buildTextField('channel', 'Channel Name', '#general', isDark, serviceColor),
        ]);
      }
    }
    // Twitch
    else if (serviceName == 'twitch') {
      if (triggerId == 'stream_online') {
        fields.addAll([
          _buildSectionTitle('Twitch Channel'),
          const SizedBox(height: 16),
          _buildTextField('channel', 'Channel Name', 'streamer_name', isDark, serviceColor),
        ]);
      }
    }
    // Weather
    else if (serviceName == 'weather') {
      if (triggerId == 'weather_change') {
        fields.addAll([
          _buildSectionTitle('Location'),
          const SizedBox(height: 16),
          _buildTextField('city', 'City', 'Paris, London', isDark, serviceColor),
        ]);
      }
    }
    // Trello
    else if (serviceName == 'trello') {
      if (triggerId == 'new_card') {
        fields.addAll([
          _buildSectionTitle('Trello Board'),
          const SizedBox(height: 16),
          _buildTextField('board_id', 'Board ID', 'abc123def456', isDark, serviceColor),
        ]);
      }
    }
    
    // If no fields configured, show "no config needed" message
    if (fields.isEmpty) {
      fields.add(
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 64,
                  color: serviceColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'No configuration needed',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This trigger works automatically',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return fields;
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildTextField(String key, String label, String hint, bool isDark, Color serviceColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controllers[key],
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: serviceColor, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator(int current, int total) {
    return Row(
      children: List.generate(total, (index) {
        final step = index + 1;
        final isActive = step == current;
        final isCompleted = step < current;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: isCompleted || isActive
                        ? const Color(0xFF10B981)
                        : Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (step < total) const SizedBox(width: 4),
            ],
          ),
        );
      }),
    );
  }

  List<Widget> _buildParameterFields(bool isDark) {
    return _controllers.entries.map((entry) {
      final key = entry.key;
      final controller = entry.value;
      final label = _formatLabel(key);

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: _getPlaceholder(key),
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _getServiceColor(), width: 2),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _formatLabel(String key) {
    return key
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _getPlaceholder(String key) {
    switch (key) {
      case 'from':
        return 'sender@example.com';
      case 'subject':
        return 'invoice';
      case 'event_title':
      default:
        return 'Enter value...';
    }
  }

  Widget _buildTimerDropdown(bool isDark, Color serviceColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choisir un intervalle *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedInterval,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: serviceColor, width: 2),
              ),
            ),
            dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
            ),
            items: const [
              DropdownMenuItem(
                value: 'every_minute',
                child: Text('Chaque minute'),
              ),
              DropdownMenuItem(
                value: 'every_5_minutes',
                child: Text('Toutes les 5 minutes'),
              ),
              DropdownMenuItem(
                value: 'every_hour',
                child: Text('Chaque heure'),
              ),
              DropdownMenuItem(
                value: 'every_day',
                child: Text('Chaque jour'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedInterval = value;
                  _params['interval'] = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }
}
