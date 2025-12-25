// misc-queues.js
// ==============
// Miscellaneous task processing for Firestore-based queue

var firebaseAdminSingleton = require('./firebase-admin-singleton');
var db = firebaseAdminSingleton.getFirestore();

var tools = require('./tools');
var storageHelper = require('./storage-helper');

module.exports = {
  /**
   * Get a serving URL for an image and update Firestore
   * Uses direct Storage URL instead of App Engine serving URL
   */
  processServingUrlTask: async function(data) {
    console.log(`Getting public URL for: ${data.path}`);

    var urlString = storageHelper.getPublicUrl(data.path);
    console.log('Got public URL:', urlString);

    // Update the original image document
    await db.collection('originalImages').doc(data.imageId).update({
      servingUrl: urlString
    });

    console.log('Updated original image with serving URL');
  },

  /**
   * Verify a user (admin action)
   */
  processVerifyUserTask: async function(data) {
    console.log(`Verifying user: ${data.userId}`);

    // Create user document
    await db.collection('users').doc(data.userId).set({
      name: data.name,
      email: data.email,
      verifiedAt: new Date()
    });

    // Remove the request
    await db.collection('userRequests').doc(data.userId).delete();

    console.log('User verified');
  },

  /**
   * Notify admin of verification request via SMS
   */
  processNotifyAdminTask: async function(data) {
    console.log(`Processing notification request for user: ${data.userId}`);

    // Check if already notified
    var requestDoc = await db.collection('userRequests').doc(data.userId).get();

    if (requestDoc.exists && !requestDoc.data().notified) {
      // Send SMS
      tools.sendSMStoAndrew('Someone has requested access to the watermarking web app.');

      // Mark as notified
      await db.collection('userRequests').doc(data.userId).update({
        notified: true
      });

      console.log('SMS notification sent to Andrew');
    } else {
      console.log('Notification already sent or request not found');
    }
  }
};
