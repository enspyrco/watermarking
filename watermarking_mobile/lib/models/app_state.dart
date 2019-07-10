import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:watermarking_mobile/models/bottom_nav_view_model.dart';
import 'package:watermarking_mobile/models/detected_image_view_model.dart';
import 'package:watermarking_mobile/models/image_reference.dart';
import 'package:watermarking_mobile/models/images_view_model.dart';
import 'package:watermarking_mobile/models/problem.dart';
import 'package:watermarking_mobile/models/upload_item.dart';
import 'package:watermarking_mobile/models/user_model.dart';
import 'package:watermarking_mobile/utilities/hash_utilities.dart';

class AppState {
  AppState(
      {@required this.user,
      @required this.bottomNav,
      @required this.upload,
      @required this.images,
      @required this.detectedImage,
      @required this.problems});

  final UserModel user;
  final BottomNavViewModel bottomNav;
  final UploadItem upload;
  final ImagesViewModel images;
  final DetectedImageViewModel detectedImage;
  final List<Problem> problems;

  static AppState intialState() => AppState(
      user: UserModel(waiting: true),
      bottomNav: BottomNavViewModel(index: 0),
      upload: UploadItem(latestEvent: UploadingEvent.processed),
      images: ImagesViewModel(images: <ImageReference>[]),
      detectedImage: DetectedImageViewModel(
          watermarkDetectionProgress: "", watermarkDetectionResult: ""),
      problems: <Problem>[]);

  AppState copyWith(
      {UserModel user,
      BottomNavViewModel bottomNav,
      UploadItem upload,
      ImagesViewModel images,
      DetectedImageViewModel detectedImage,
      List<Problem> problems}) {
    return AppState(
        user: user ?? this.user,
        bottomNav: bottomNav ?? this.bottomNav,
        upload: upload ?? this.upload,
        images: images ?? this.images,
        detectedImage: detectedImage ?? this.detectedImage,
        problems: problems ?? this.problems);
  }

  @override
  int get hashCode =>
      hash6(user, bottomNav, upload, images, detectedImage, problems);

  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          user == other.user &&
          bottomNav == other.bottomNav &&
          upload == other.upload &&
          images == other.images &&
          detectedImage == other.detectedImage &&
          problems == other.problems;

  @override
  String toString() {
    return 'AppState{user: $user, bottomNav: $bottomNav, upload: $upload, images: $images, detectedImage: $detectedImage, problems: $problems}';
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'user': user,
        'bottomNav': bottomNav,
        'uploading': upload,
        'images': images,
        'detectedImage': detectedImage,
        'problems': problems,
      };
}
