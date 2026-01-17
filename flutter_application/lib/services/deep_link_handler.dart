import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';

class DeepLinkHandler {
  static StreamController<Uri>? _streamController;
  static StreamSubscription? _linkSubscription;
  static final AppLinks _appLinks = AppLinks();
  
  static Stream<Uri> get deepLinkStream {
    _streamController ??= StreamController<Uri>.broadcast();
    return _streamController!.stream;
  }

  /// Initialiser le listener de deep links
  static Future<void> initialize() async {
    // Récupérer le deep link initial (si l'app a été lancée via deep link)
    try {
      final Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint('[DeepLinkHandler] Initial deep link: $initialUri');
        _streamController?.add(initialUri);
      }
    } catch (e) {
      debugPrint('[DeepLinkHandler] Error getting initial link: $e');
    }

    // Écouter les nouveaux deep links (quand l'app est déjà ouverte)
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
      debugPrint('[DeepLinkHandler] Deep link received: $uri');
      _streamController?.add(uri);
    }, onError: (err) {
      debugPrint('[DeepLinkHandler] Error listening to deep links: $err');
    });
  }

  static void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
    _streamController?.close();
    _streamController = null;
  }
}

