import 'dart:io';
import 'package:flutter/foundation.dart';

class BackendRoutes {
  static String get baseUrl {
    const url = "https://rivetless-congratulatory-kenia.ngrok-free.dev";
    debugPrint("[BackendRoutes] Using base URL: $url");
    return url;
  }

  // Auth routes
  static const String googleAuth = "/api/auth/google";
  static const String register = "/api/register";
  static const String login = "/api/login";
  static const String user = "/api/user";
  static const String userUpdate = "/api/user/update";
  static const String userDelete = "/api/user/delete";
  static const String logout = "/api/logout";
  
  // Calendar routes
  static const String calendarEvents = "/api/calendar-events";
  
  // Services routes
  static const String services = "/api/services";
  static String serviceById(String id) => "/api/services/$id";
  static String serviceConnect(String id) => "/api/services/$id/connect";
  static String serviceDisconnect(String id) => "/api/services/$id/disconnect";
  static const String userServices = "/api/user/services";
  
  // Areas routes
  static const String areas = "/api/areas";
  static String areaById(String id) => "/api/areas/$id";
  static String areaToggle(String id) => "/api/areas/$id/toggle";
  
  // About route
  static const String about = "/api/about.json";
}