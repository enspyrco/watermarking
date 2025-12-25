// marking-queues.js
// =================
// Marking task processing for Firestore-based queue

var firebaseAdminSingleton = require('./firebase-admin-singleton');
var db = firebaseAdminSingleton.getFirestore();

var execFile = require('child_process').execFile;
var { promisify } = require('util');
var execFileAsync = promisify(execFile);

var storageHelper = require('./storage-helper');

// Promisify storage helper functions
function downloadFileAsync(gcsPath, localPath) {
  return new Promise((resolve, reject) => {
    storageHelper.downloadFile(gcsPath, localPath, (error) => {
      if (error) reject(error);
      else resolve();
    });
  });
}

function uploadFileAsync(localPath, gcsPath) {
  return new Promise((resolve, reject) => {
    storageHelper.uploadFile(localPath, gcsPath, (error) => {
      if (error) reject(error);
      else resolve();
    });
  });
}


module.exports = {
  /**
   * Process a complete marking task:
   * 1. Download original image from GCS
   * 2. Run mark-image binary
   * 3. Upload marked image to GCS
   * 4. Update Firestore with result
   */
  processMarkingTask: async function(data) {
    console.log(`Processing marking task for image: ${data.name}`);

    // Step 1: Download the original image
    var timestamp = String(Date.now());
    var filePath = '/tmp/' + timestamp + '/' + data.name;

    console.log('Downloading image from:', data.path);
    await downloadFileAsync(data.path, filePath);
    console.log('Downloaded to:', filePath);

    // Step 2: Run the marking binary
    console.log(`Marking image with message "${data.message}" at strength ${data.strength}`);
    var { stdout } = await execFileAsync('./mark-image', [
      filePath,
      data.name,
      data.message,
      String(data.strength)
    ]);
    console.log('Mark output:', stdout);

    // Step 3: Upload the marked image
    var markedFilePath = filePath + '-marked.png';
    var markedGcsPath = 'marked-images/' + data.userId + '/' + timestamp + '/' + data.name + '.png';

    console.log('Uploading marked image to:', markedGcsPath);
    await uploadFileAsync(markedFilePath, markedGcsPath);

    // Step 4: Get public URL (using direct Storage URL instead of App Engine serving URL)
    var servingUrl = storageHelper.getPublicUrl(markedGcsPath);
    console.log('Got public URL:', servingUrl);

    // Step 5: Update Firestore with the marked image data
    await db.collection('markedImages').doc(data.markedImageId).update({
      path: markedGcsPath,
      servingUrl: servingUrl,
      processedAt: new Date()
    });

    console.log('Marking task completed successfully');
  }
};
