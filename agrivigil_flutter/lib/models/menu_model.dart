import 'package:flutter/material.dart';

class MenuDefinition {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final String ariaLabel;

  const MenuDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.ariaLabel,
  });
}

class MenuDefinitions {
  static const List<MenuDefinition> allMenus = [
    MenuDefinition(
      id: 'dashboard',
      name: 'Dashboard',
      description: 'Main monitoring dashboard',
      icon: Icons.bar_chart,
      ariaLabel: 'View monitoring dashboard',
    ),
    MenuDefinition(
      id: 'administration',
      name: 'Administration',
      description: 'User and role management',
      icon: Icons.person,
      ariaLabel: 'User and role management',
    ),
    MenuDefinition(
      id: 'inspection-planning',
      name: 'Inspection Planning',
      description: 'Plan inspection visits',
      icon: Icons.calendar_today,
      ariaLabel: 'Plan inspection visits',
    ),
    MenuDefinition(
      id: 'field-execution',
      name: 'Field Execution',
      description: 'Execute field inspections',
      icon: Icons.camera_alt,
      ariaLabel: 'Execute field inspections',
    ),
    MenuDefinition(
      id: 'seizure-logging',
      name: 'Seizure Logging',
      description: 'Log seized items',
      icon: Icons.inventory_2,
      ariaLabel: 'Log seized items',
    ),
    MenuDefinition(
      id: 'lab-interface',
      name: 'Lab Interface',
      description: 'Lab sample tracking',
      icon: Icons.science,
      ariaLabel: 'Lab sample tracking',
    ),
    MenuDefinition(
      id: 'legal-module',
      name: 'Legal Module',
      description: 'Legal enforcement',
      icon: Icons.gavel,
      ariaLabel: 'Legal enforcement',
    ),
    MenuDefinition(
      id: 'report-audit',
      name: 'Reports & Audit',
      description: 'View reports and audit logs',
      icon: Icons.file_copy,
      ariaLabel: 'View reports and audit logs',
    ),
    MenuDefinition(
      id: 'agri-forms-module',
      name: 'Agri-Forms Portal',
      description: 'Access agricultural forms portal',
      icon: Icons.edit_document,
      ariaLabel: 'Access agricultural forms portal',
    ),
    MenuDefinition(
      id: 'qc-module',
      name: 'QC Department',
      description: 'Quality Control management and processes',
      icon: Icons.verified_user,
      ariaLabel: 'Quality Control Department',
    ),
  ];

  static MenuDefinition? getMenuById(String id) {
    try {
      return allMenus.firstWhere((menu) => menu.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<MenuDefinition> getMenusByIds(List<String> ids) {
    return allMenus.where((menu) => ids.contains(menu.id)).toList();
  }
}
