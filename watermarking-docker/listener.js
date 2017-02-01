

var firebaseAdminSingleton = require('./firebase-admin-singleton');
var firebaseAdmin = firebaseAdminSingleton.getAdmin();

var Queue = require('firebase-queue');

// setup variables for running shell script and reading files 
var execFile = require('child_process').execFile;
var fs = require('fs');

var tools = require('./tools');

var markingQueues = require('./marking-queues');
var detectionQueues = require('./detection-queues');

console.log('Setting up queues...');

markingQueues.setup(); 
detectionQueues.setup();

var queueRef = firebaseAdmin.database().ref('queue');

/////////////////////////////////////////////////////
//
// get serving url queue - for original image 
// 
/////////////////////////////////////////////////////
var queue = new Queue(queueRef, function(data, progress, resolve, reject) {

  console.log("Task added to queue: "+data);

  var updateDBCallback = function(urlString) {

    // Get a reference to the image's db entry 
    var originalImageRef = firebaseAdmin.database().ref("original-images/"+data.uid+"/"+data.imageKey);

    originalImageRef.update({
      'servingUrl': urlString
    });

    resolve();

  };

  tools.getServingUrl(data.path, updateDBCallback);

});

/////////////////////////////////////////////////////
//
// verify users queue - when admin verifies a user, add their info to db 
// 
/////////////////////////////////////////////////////
var verifyUsersQueueOptions = {
  'specId': 'spec_1'
};
var verifyUsersQueue = new Queue(queueRef, verifyUsersQueueOptions, function(data, progress, resolve, reject) {
  
  console.log('Verifying user with id: '+data.uid);

  // Get a reference to the users section of the db 
  var userRef = firebaseAdmin.database().ref("users").child(data.uid);

  // create an entry to indicate user is verified 
  userRef.set({
    name: data.name,
    email: data.email
  });

  // remove the request 
  var requestRef = firebaseAdmin.database().ref("user-requests").child(data.uid);
  requestRef.set(null);

  console.log('Verifed.');

  resolve();

});

console.log('Queue setup finished.');

