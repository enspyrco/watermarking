import 'package:meta/meta.dart';
import 'package:watermarking_mobile/models/detection_item.dart';
import 'package:watermarking_mobile/models/original_image_reference.dart';
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

class ActionSetOriginalImages {
  const ActionSetOriginalImages({@required this.images});
  final List<OriginalImageReference> images;
}

class ActionSetDetectionItems {
  const ActionSetDetectionItems({@required this.items});
  final List<DetectionItem> items;
}

class ActionSetBottomNav {
  const ActionSetBottomNav({@required this.index});
  final int index;
}

class ActionShowBottomSheet {
  const ActionShowBottomSheet({@required this.show});
  final bool show;
}

// TODO(nickm): when the image reference contains the size,
// just send the image reference
class ActionSetSelectedImage {
  const ActionSetSelectedImage(
      {@required this.image, @required this.height, @required this.width});
  final OriginalImageReference image;
  final int height;
  final int width;
}

class ActionPerformExtraction {
  const ActionPerformExtraction({@required this.width, @required this.height});
  final int width;
  final int height;
}

// when an extracted image is returned from the native view we dispatch this
// action and rely on middleware to dispatch a new action to add the data
// to the store
class ActionProcessExtraction {
  const ActionProcessExtraction({@required this.filePaths});
  final List<String> filePaths;
}

// when middleware sees ActionProcessExtractedImage it creates a unique id and
// TODO(nickm): update this documentation
// starts an upload (with the id as metadata) and also dispatches an action
// to add a new extracted image (with id as a member)
class ActionAddDetectionItem {
  const ActionAddDetectionItem(
      {@required this.id, @required this.extractedPath, @required this.bytes});
  final String id;
  final String extractedPath;
  final int bytes;
}

class ActionStartUpload {
  const ActionStartUpload({@required this.id, @required this.filePath});
  final String id;
  final String filePath;
}

class ActionSetUploadPaused {
  const ActionSetUploadPaused({@required this.id});
  final String id;
}

class ActionSetUploadResumed {
  const ActionSetUploadResumed({@required this.id});
  final String id;
}

// this action will also trigger middleware to create a db entry
// to indicate status (file uploaded, waiting for result)
class ActionSetUploadSuccess {
  const ActionSetUploadSuccess({@required this.id});
  final String id;
}

class ActionSetUploadProgress {
  const ActionSetUploadProgress({@required this.id, @required this.bytes});
  final String id;
  final int bytes;
}

class ActionCancelUpload {
  const ActionCancelUpload({@required this.id});
  final String id;
}

class ActionSetDetectionProgress {
  const ActionSetDetectionProgress(
      {@required this.progress, @required this.result});
  final String progress;
  final String result;
}
