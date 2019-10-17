import 'package:watermarking_mobile/utilities/hash_utilities.dart';

class BottomNavViewModel {
  const BottomNavViewModel({this.index, this.shouldShowBottomSheet});

  final int index;
  final bool shouldShowBottomSheet;

  BottomNavViewModel copyWith(
      {final int index, final bool shouldShowBottomSheet}) {
    return BottomNavViewModel(
        index: index ?? this.index,
        shouldShowBottomSheet:
            shouldShowBottomSheet ?? this.shouldShowBottomSheet);
  }

  @override
  int get hashCode => hash2(index, shouldShowBottomSheet);

  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          index == other.index &&
          shouldShowBottomSheet == other.shouldShowBottomSheet;

  @override
  String toString() {
    return 'BottomNavViewModel{index: $index, shouldShowBottomSheet: $shouldShowBottomSheet}';
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'index': index,
        'shouldShowBottomSheet': shouldShowBottomSheet
      };
}
