import 'package:flutter/foundation.dart';
import 'package:flutter_admin_app/features/trees/models/tree_group.dart';
import 'package:flutter_admin_app/features/trees/repositories/tree_repository.dart';

class TreeGroupEditViewModel extends ChangeNotifier {
  final TreeRepository _repository = TreeRepository();
  // final _supabase = Supabase.instance.client; // Removed as we use repository now

  // Form State
  String? _id;
  String _title = '';
  String _description = '';
  List<TreeGroupMember> _members = [];
  bool _isLoading = false;

  // Getters
  String get title => _title;
  String get description => _description;
  List<TreeGroupMember> get members => _members;
  bool get isLoading => _isLoading;
  bool get isValid => _title.isNotEmpty && _members.length >= 2;
  bool get isEditing => _id != null;

  // Constructor for Edit Mode
  TreeGroupEditViewModel({TreeGroup? initialGroup}) {
    if (initialGroup != null) {
      _id = initialGroup.id;
      _title = initialGroup.name;
      _description = initialGroup.description;
      _members = List.from(initialGroup.members);
    }
  }

  // Setters
  void setTitle(String val) {
    _title = val;
    notifyListeners();
  }

  void setDescription(String val) {
    _description = val;
    notifyListeners();
  }

  // Load Full Detail (e.g. including images)
  Future<void> loadGroupDetail(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final group = await _repository.getTreeGroupById(id);
      _id = group.id;
      _title = group.name;
      _description = group.description;
      _members = List.from(group.members);
    } catch (e) {
      debugPrint('Error loading group detail: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Actions
  void addMember(TreeGroupMember member) {
    // Prevent duplicates
    if (_members.any((m) => m.treeId == member.treeId)) return;

    _members.add(member);
    notifyListeners();
  }

  void removeMember(int index) {
    _members.removeAt(index);
    notifyListeners();
  }

  void reorderMembers(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _members.removeAt(oldIndex);
    _members.insert(newIndex, item);
    notifyListeners();
  }

  Future<bool> saveGroup() async {
    if (!isValid) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final membersData = _members.map((m) {
        return {
          'treeId': int.tryParse(m.treeId) ?? 0,
          'keyCharacteristics': m.keyCharacteristics,
          // sort_order is handled by array index in backend service
        };
      }).toList();

      final data = {
        'group_name':
            _title, // Ensure consistent naming with backend expectation
        'description': _description,
        'members': membersData,
      };

      if (isEditing) {
        await _repository.updateTreeGroup(_id!, data);
      } else {
        await _repository.createTreeGroup(data);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error saving tree group: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteGroup() async {
    if (!isEditing) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await _repository.deleteTreeGroup(_id!);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting group: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  TreeGroup toGroup() {
    return TreeGroup(
      id: _id ?? '',
      name: _title,
      description: _description,
      members: _members,
    );
  }
}
