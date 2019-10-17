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
    final SerializableFinder imageTabIconFinder =
        find.byValueKey('ImageTabIcon');
    final SerializableFinder imageTabImageFinder =
        find.byValueKey('ImageTabImage');
    final SerializableFinder accountButtonFinder =
        find.byValueKey('AccountButton');
    final SerializableFinder originalImageFinder =
        find.byValueKey('OriginalImageInkWell0');
    final SerializableFinder scanFAB = find.byValueKey('ScanFAB');

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
      // select an image
      await driver.tap(imageTabIconFinder);
      await driver.tap(originalImageFinder);
      await driver.tap(scanFAB);
    });
  });
}
