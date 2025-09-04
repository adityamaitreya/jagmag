import 'package:cloud_firestore/cloud_firestore.dart';

class JagmagIssue {
  final String id;
  final String description;
  final String urgency;
  final String imageUrl;
  final DateTime timestamp;
  final Map<String, dynamic> location;
  final String userId;
  final String username;
  final String status;
  final String? assignedDepartment;
  final int upvotes;
  final int downvotes;
  final Map<String, String> voters;
  final int commentsCount;
  final int? affectedUsersCount;
  final List<String>? affectedUserIds;
  final String? originalSpokenText;
  final String? userInputLanguage;
  final String? aiRiskAnalysis;
  final DateTime? resolutionTimestamp;
  final String? lastStatusUpdateBy;
  final DateTime? lastStatusUpdateAt;
  final bool isUnresolved;
  final String? duplicateOfIssueId;
  final List<String>? evidenceImages;
  final int? collaborationCount;
  final DateTime? lastCollaborationAt;
  final List<Map<String, dynamic>>? statusUpdates;

  JagmagIssue({
    required this.id,
    required this.description,
    required this.urgency,
    required this.imageUrl,
    required this.timestamp,
    required this.location,
    required this.userId,
    required this.username,
    required this.status,
    this.assignedDepartment,
    required this.upvotes,
    required this.downvotes,
    required this.voters,
    required this.commentsCount,
    this.affectedUsersCount,
    this.affectedUserIds,
    this.originalSpokenText,
    this.userInputLanguage,
    this.aiRiskAnalysis,
    this.resolutionTimestamp,
    this.lastStatusUpdateBy,
    this.lastStatusUpdateAt,
    required this.isUnresolved,
    this.duplicateOfIssueId,
    this.evidenceImages,
    this.collaborationCount,
    this.lastCollaborationAt,
    this.statusUpdates,
  });

  factory JagmagIssue.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return JagmagIssue(
      id: doc.id,
      description: data['description'] ?? '',
      urgency: data['urgency'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      location: data['location'] ?? {},
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      status: data['status'] ?? 'Pending',
      assignedDepartment: data['assignedDepartment'],
      upvotes: data['upvotes'] ?? 0,
      downvotes: data['downvotes'] ?? 0,
      voters: Map<String, String>.from(data['voters'] ?? {}),
      commentsCount: data['commentsCount'] ?? 0,
      affectedUsersCount: data['affectedUsersCount'],
      affectedUserIds: data['affectedUserIds'] != null
          ? List<String>.from(data['affectedUserIds'])
          : null,
      originalSpokenText: data['originalSpokenText'],
      userInputLanguage: data['userInputLanguage'],
      aiRiskAnalysis: data['aiRiskAnalysis'],
      resolutionTimestamp: data['resolutionTimestamp'] != null
          ? (data['resolutionTimestamp'] as Timestamp).toDate()
          : null,
      lastStatusUpdateBy: data['lastStatusUpdateBy'],
      lastStatusUpdateAt: data['lastStatusUpdateAt'] != null
          ? (data['lastStatusUpdateAt'] as Timestamp).toDate()
          : null,
      isUnresolved: data['isUnresolved'] ?? true,
      duplicateOfIssueId: data['duplicateOfIssueId'],
      evidenceImages: data['evidenceImages'] != null
          ? List<String>.from(data['evidenceImages'])
          : null,
      collaborationCount: data['collaborationCount'],
      lastCollaborationAt: data['lastCollaborationAt'] != null
          ? (data['lastCollaborationAt'] as Timestamp).toDate()
          : null,
      statusUpdates: data['statusUpdates'] != null
          ? List<Map<String, dynamic>>.from(data['statusUpdates'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'description': description,
      'urgency': urgency,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'location': location,
      'userId': userId,
      'username': username,
      'status': status,
      'assignedDepartment': assignedDepartment,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'voters': voters,
      'commentsCount': commentsCount,
      'affectedUsersCount': affectedUsersCount,
      'affectedUserIds': affectedUserIds,
      'originalSpokenText': originalSpokenText,
      'userInputLanguage': userInputLanguage,
      'aiRiskAnalysis': aiRiskAnalysis,
      'resolutionTimestamp': resolutionTimestamp != null
          ? Timestamp.fromDate(resolutionTimestamp!)
          : null,
      'lastStatusUpdateBy': lastStatusUpdateBy,
      'lastStatusUpdateAt': lastStatusUpdateAt != null
          ? Timestamp.fromDate(lastStatusUpdateAt!)
          : null,
      'isUnresolved': isUnresolved,
      'duplicateOfIssueId': duplicateOfIssueId,
      'evidenceImages': evidenceImages,
      'collaborationCount': collaborationCount,
      'lastCollaborationAt': lastCollaborationAt != null
          ? Timestamp.fromDate(lastCollaborationAt!)
          : null,
      'statusUpdates': statusUpdates,
    };
  }

  JagmagIssue copyWith({
    String? id,
    String? description,
    String? urgency,
    String? imageUrl,
    DateTime? timestamp,
    Map<String, dynamic>? location,
    String? userId,
    String? username,
    String? status,
    String? assignedDepartment,
    int? upvotes,
    int? downvotes,
    Map<String, String>? voters,
    int? commentsCount,
    int? affectedUsersCount,
    List<String>? affectedUserIds,
    String? originalSpokenText,
    String? userInputLanguage,
    String? aiRiskAnalysis,
    DateTime? resolutionTimestamp,
    String? lastStatusUpdateBy,
    DateTime? lastStatusUpdateAt,
    bool? isUnresolved,
    String? duplicateOfIssueId,
    List<String>? evidenceImages,
    int? collaborationCount,
    DateTime? lastCollaborationAt,
    List<Map<String, dynamic>>? statusUpdates,
  }) {
    return JagmagIssue(
      id: id ?? this.id,
      description: description ?? this.description,
      urgency: urgency ?? this.urgency,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
      location: location ?? this.location,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      status: status ?? this.status,
      assignedDepartment: assignedDepartment ?? this.assignedDepartment,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      voters: voters ?? this.voters,
      commentsCount: commentsCount ?? this.commentsCount,
      affectedUsersCount: affectedUsersCount ?? this.affectedUsersCount,
      affectedUserIds: affectedUserIds ?? this.affectedUserIds,
      originalSpokenText: originalSpokenText ?? this.originalSpokenText,
      userInputLanguage: userInputLanguage ?? this.userInputLanguage,
      aiRiskAnalysis: aiRiskAnalysis ?? this.aiRiskAnalysis,
      resolutionTimestamp: resolutionTimestamp ?? this.resolutionTimestamp,
      lastStatusUpdateBy: lastStatusUpdateBy ?? this.lastStatusUpdateBy,
      lastStatusUpdateAt: lastStatusUpdateAt ?? this.lastStatusUpdateAt,
      isUnresolved: isUnresolved ?? this.isUnresolved,
      duplicateOfIssueId: duplicateOfIssueId ?? this.duplicateOfIssueId,
      evidenceImages: evidenceImages ?? this.evidenceImages,
      collaborationCount: collaborationCount ?? this.collaborationCount,
      lastCollaborationAt: lastCollaborationAt ?? this.lastCollaborationAt,
      statusUpdates: statusUpdates ?? this.statusUpdates,
    );
  }
}
