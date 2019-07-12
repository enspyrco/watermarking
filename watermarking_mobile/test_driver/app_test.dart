// Imports the Flutter Driver API
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('CrowdLeague App', () {
    // First, define the Finders. We can use these to locate Widgets from the
    // test suite. Note: the Strings provided to the `byValueKey` method must
    // be the same as the Strings we used for the Keys in step 1.
    final SerializableFinder homeTabFinder = find.byValueKey('HomeTabIcon');
    final SerializableFinder profileTabFinder =
        find.byValueKey('ProfileTabIcon');
    final SerializableFinder conversationsTabFinder =
        find.byValueKey('ConversationsTabIcon');
    final SerializableFinder mainPicFinder = find.byValueKey('MainPic');
    final SerializableFinder addProfilePicButton =
        find.byValueKey('AddProfilePicButton');
    final SerializableFinder galleryFinder =
        find.byValueKey('GalleryOptionIcon');
    final SerializableFinder bottomSheetDismissFinder =
        find.byValueKey('UploadingBottomSheetDismissButton');
    final SerializableFinder uploadsObserverFinder =
        find.byValueKey('UploadsObserver');
    final SerializableFinder uploadsObserverTextFinder =
        find.byValueKey('UploadsObserverText');

    final SerializableFinder accountButtonFinder =
        find.byValueKey('AccountButton');

    FlutterDriver driver;

    // Connect to the Flutter driver before running any tests
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('start upload and navigate through views', () async {
      // start an upload
      await driver.tap(profileTabFinder);
      await driver.tap(mainPicFinder);
      await driver.tap(addProfilePicButton);
      await driver.tap(galleryFinder);
      // check bottom sheet is present and uploads observer is hidden
      await driver.waitFor(bottomSheetDismissFinder);
      await driver.waitForAbsent(uploadsObserverTextFinder);
      // dismiss bottom sheet
      await driver.tap(bottomSheetDismissFinder);
      // check BottomSheet has gone and UploadsObserver shows 1 upload
      await driver.waitForAbsent(bottomSheetDismissFinder);
      await driver.waitFor(uploadsObserverFinder);
      expect(await driver.getText(uploadsObserverTextFinder), equals('1'));
      // navigate to uploads page
      await driver.tap(uploadsObserverFinder);

      // Note: currently the mockdatabaseservice returns a count (starting at 1)
      // for each requested id so the key will be:
      final SerializableFinder uploadsListItemFinder =
          find.byValueKey('UploadsListItemDismissible1');
      await driver.waitFor(uploadsListItemFinder);
    });

    // test('add simultaneous uploads', () async {
    //   await driver.tap(profileTabFinder);
    //   await driver.tap(mainPicFinder);
    //   await driver.tap(addProfilePicButton);
    //   await driver.tap(galleryFinder);
    //   await driver.tap(mainPicFinder);
    //   await driver.tap(addProfilePicButton);
    //   await driver.tap(galleryFinder);
    // });

    // test that a widget contains the expected text
    //   expect(await driver.getText(counterTextFinder), "1");
  });
}
