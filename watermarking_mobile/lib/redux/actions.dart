import 'package:meta/meta.dart';
import 'package:watermarking_mobile/models/image_reference.dart';
import 'package:watermarking_mobile/models/problem.dart';

class ActionSignin {
  const ActionSignin();
}

class ActionSignout {
  const ActionSignout();
}

class ActionAddProblem {
  const ActionAddProblem({@required this.problem});
  final Problem problem;
}

class ActionRemoveProblem {
  const ActionRemoveProblem({@required this.problem});
  final Problem problem;
}

class ActionObserveAuthState {
  const ActionObserveAuthState();
}

class ActionSetAuthState {
  const ActionSetAuthState({@required this.userId, @required this.photoUrl});
  final String userId;
  final String photoUrl;
}

class ActionSetProfilePicUrl {
  const ActionSetProfilePicUrl({@required this.url});
  final String url;
}

class ActionSetProfile {
  const ActionSetProfile({@required this.name, @required this.email});
  final String name;
  final String email;
}

class ActionSetImages {
  const ActionSetImages({@required this.images});
  final List<ImageReference> images;
}

// TODO(nickm): when the image reference contains the size,
// just send the image reference
class ActionSetSelectedImage {
  const ActionSetSelectedImage(
      {@required this.image, @required this.height, @required this.width});
  final ImageReference image;
  final int height;
  final int width;
}

class ActionStartImageUpload {
  const ActionStartImageUpload(
      {@required this.id, @required this.filePath, this.totalBytes});
  final String id;
  final String filePath;
  final int totalBytes;
}

class ActionSetImageUploadPaused {
  const ActionSetImageUploadPaused({@required this.id});
  final String id;
}

class ActionSetImageUploadResumed {
  const ActionSetImageUploadResumed({@required this.id});
  final String id;
}

// this action will also trigger middleware to create a db entry
// to indicate status (file uploaded, waiting for result)
class ActionSetImageUploadSuccess {
  const ActionSetImageUploadSuccess({@required this.id});
  final String id;
}

class ActionSetImageUploadProgress {
  const ActionSetImageUploadProgress({@required this.id, @required this.bytes});
  final String id;
  final int bytes;
}

class ActionRemoveUploadItem {
  const ActionRemoveUploadItem({@required this.id});
  final String id;
}

class ActionCancelUpload {
  const ActionCancelUpload({@required this.id});
  final String id;
}
