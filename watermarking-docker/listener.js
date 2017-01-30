

var firebaseAdminSingleton = require('./firebase-admin-singleton');
var firebaseAdmin = firebaseAdminSingleton.getAdmin();

var Queue = require('firebase-queue');
// var admin = require('firebase-admin');

var tools = require('./tools');
var markingQueues = require('./marking-queues');

markingQueues.setup(); 

// setup variables for running shell script and reading files 
var execFile = require('child_process').execFile;
var fs = require('fs');

var detectingRef = firebaseAdmin.database().ref("detecting/incomplete");
var incompleteDetectingLogsRef = firebaseAdmin.database().ref("logs/detecting/incomplete");
// Retrieve new 'detect' entries as they are added to our database 
detectingRef.on("child_added", function(snapshot, prevChildKey) {
  var detectingEntry = snapshot.val();
  if(detectingEntry.originalPath !== null) {

    // check if there has already been an attempt 
    if(detectingEntry.attempts > 0) {
      // log the problematic entry 
      console.log("A previous attempt was already made to detect a message in file "+detectingEntry.pathOriginal);
      console.log("Incomplete detection entry is being removed and logged.");
      incompleteDetectingLogsRef.push(detectingEntry); 
      // remove the problematic entry 
      detectingRef.set(null);
      return;
    }
    
    // increment the attempts 
    detectingRef.child(snapshot.key).child('attempts').set(detectingEntry.attempts+1); 
    
    detectingRef.child(snapshot.key).child('progress').set('Server has received request and is downloading images...');

    var originalPath = '/tmp/'+snapshot.key+'/original';
    var markedPath = '/tmp/'+snapshot.key+'/marked';

    console.log("Saving original image file for detection, from gcs at location \'"+detectingEntry.pathOriginal+"\', to \'"+originalPath+"\'."); 

    // execFile: executes a file with the specified arguments
    execFile('gsutil', ['cp', 'gs://watermarking-print-and-scan.appspot.com/'+detectingEntry.pathOriginal, originalPath], function(error, stdout, stderr){
      
      if (error) { // update the db entry with the error 
        detectingRef.child(snapshot.key).child('error').set('Error downloading original image: '+error);
        console.log('Error downloading original image: '+error);
        return;
      }
      
      // Pass out stdout for docker log 
      console.log('Downloaded original image.\n'+stdout);
      // Update progress for webapp UI 
      detectingRef.child(snapshot.key).child('progress').set('Server downloaded original image, now downloading marked image...');

      console.log("Saving marked image file for detection, from gcs at location \'"+detectingEntry.pathMarked+"\', to \'"+markedPath+"\'."); 

      execFile('gsutil', ['cp', 'gs://watermarking-print-and-scan.appspot.com/'+detectingEntry.pathMarked, markedPath], function(error, stdout, stderr){
      
        if (error) { // update the db entry with the error 
          detectingRef.child(snapshot.key).child('error').set('Error downloading marked image: '+error);
          console.log('Error downloading marked image: '+error);
          return;
        }

        // Pass out stdout for docker log 
        console.log('Downloaded marked image.\n'+stdout);
        // Update progress for webapp UI 
        detectingRef.child(snapshot.key).child('progress').set('Server downloaded images, detecting watermark...');

        console.log('Detecting message...');

        execFile('./detect-wm', [snapshot.key, originalPath, markedPath], function(error, stdout, stderr){
    
          if (error) { // update the db entry with the error 
            detectingRef.child(snapshot.key).child('error').set('Error detecting watermark: '+error);
            console.log('Error detecting watermark: '+error);
            return;
          }

          // Read in the output.json file 
          var resultsJson = JSON.parse(fs.readFileSync('/tmp/'+snapshot.key+'.json', 'utf8'));

          // Pass out stdout for docker log 
          console.log('Detected watermark.\n'+stdout);
          // Update progress for webapp UI 
          detectingRef.child(snapshot.key).child('results').set(resultsJson);
          
          console.log('Message detected and results saved to database.');

        });

      });

    });

  }
});

console.log('Listeners initialised. Setting up queue...');

var queueRef = firebaseAdmin.database().ref('queue');
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

