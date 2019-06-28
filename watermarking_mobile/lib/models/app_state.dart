import 'package:meta/meta.dart';
import 'package:watermarking_mobile/models/image_reference.dart';
import 'package:watermarking_mobile/models/images_view_model.dart';
import 'package:watermarking_mobile/models/problem.dart';
import 'package:watermarking_mobile/models/upload_item.dart';
import 'package:watermarking_mobile/models/user_model.dart';
import 'package:watermarking_mobile/utilities/hash_utilities.dart';

class AppState {
  AppState(
      {@required this.user,
      @required this.upload,
      @required this.images,
      @required this.problems});

  final UserModel user;
  final UploadItem upload;
  final ImagesViewModel images;
  final List<Problem> problems;

  static AppState intialState() => AppState(
      user: UserModel(waiting: true),
      upload: null,
      images: ImagesViewModel(images: <ImageReference>[]),
      problems: <Problem>[]);

  AppState copyWith(
      {UserModel user,
      UploadItem upload,
      ImagesViewModel images,
      List<Problem> problems}) {
    return AppState(
        user: user ?? this.user,
        upload: upload ?? this.upload,
        images: images ?? this.images,
        problems: problems ?? this.problems);
  }

  @override
  int get hashCode => hash4(user, upload, images, problems);

  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          user == other.user &&
          upload == other.upload &&
          images == other.images &&
          problems == other.problems;

  @override
  String toString() {
    return 'AppState{user: $user, upload: $upload, images: $images, problems: $problems}';
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'user': user,
        'uploading': upload,
        'images': images,
        'problems': problems,
      };
}
