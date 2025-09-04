class JagmagCategory {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String department;
  final int priority;
  final bool isActive;

  JagmagCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.department,
    required this.priority,
    required this.isActive,
  });

  factory JagmagCategory.fromMap(Map<String, dynamic> map) {
    return JagmagCategory(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? '',
      department: map['department'] ?? '',
      priority: map['priority'] ?? 0,
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'department': department,
      'priority': priority,
      'isActive': isActive,
    };
  }
}
