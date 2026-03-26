// ignore_for_file: prefer_final_fields
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/tree.dart';
import '../models/create_tree_request.dart';
import '../repositories/master_tree_repository.dart';
import '../repositories/master_tree_media_repository.dart';

part 'parts/tree_sourcing_viewmodel_list.part.dart';
part 'parts/tree_sourcing_viewmodel_detail.part.dart';
part 'parts/tree_sourcing_viewmodel_drive.part.dart';

class TreeSourcingViewModel extends ChangeNotifier {
  final _repository = MasterTreeRepository();
  final _mediaRepo = MasterTreeMediaRepository();

  List<Tree> _trees = [];
  int _currentPage = 1;
  int _totalCount = 0;
  bool _hasMore = true;
  static const int _pageSize = 5;

  List<Tree> get trees => _trees;
  int get currentPage => _currentPage;
  int get totalCount => _totalCount;
  bool get hasMore => _hasMore;
  int get totalPages => (_totalCount / _pageSize).ceil();

  Tree? _selectedTree;
  Tree? get selectedTree => _selectedTree;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  bool _hasChanges = false;
  bool get hasChanges => _hasChanges;

  final Map<String, dynamic> _pendingImages = {};
  Map<String, dynamic> get pendingImages => _pendingImages;

  final Map<String, String> _imageSources = {};
  Map<String, String> get imageSources => _imageSources;

  final Map<String, bool> _fileMissing = {};
  Map<String, bool> get fileMissing => _fileMissing;

  TreeSourcingViewModel() {
    loadTrees();
  }

  /// Wrapper for notifyListeners to be accessible in parts
  void notify() => notifyListeners();
}
