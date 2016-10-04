var firebase = require("firebase");

// Initialize the app with a service account, granting admin privileges
firebase.initializeApp({
  databaseURL: "https://watermarking-print-and-scan.firebaseio.com/",
  serviceAccount: "/keys/WatermarkingPrintAndScan-8705059a4ba1.json" // /keys/
});

// setup variables for running shell script 
var sys = require('util');
var execFile = require('child_process').execFile;

// Setup variables for db access 
// As an admin, the app has access to read and write all data, regardless of Security Rules
var db = firebase.database();
var markingRef = db.ref("marking/incomplete");
var markedRef = db.ref("marked-images");

// Retrieve new 'marking' entries as they are added to our database 
markingRef.on("child_added", function(snapshot, prevChildKey) {
  var newEntry = snapshot.val();
  if(newEntry.path !== null) {

    markingRef.child(snapshot.key).child('progress').set('Server has received request and is downloading original image...');

    // create a timestamp so we can store the marked image with a unique path 
    var timestamp = String(Date.now());
    var filePath = '/tmp/'+snapshot.key+'/'+newEntry.name;

    // execFile: executes a file with the specified arguments
    execFile('gsutil', ['cp', 'gs://watermarking-print-and-scan.appspot.com/'+newEntry.path, filePath], function(error, stdout, stderr){
      
      if (error) { // update the db entry with the error 
        markingRef.child(snapshot.key).child('error').set('Error downloading original image: '+error);
        console.log('Error downloading original image: '+error);
        return;
      }
      
      // Pass out stdout for docker log 
      console.log('Downloaded image.\n'+stdout);
      // Update progress for webapp UI 
      markingRef.child(snapshot.key).child('progress').set('Server downloaded image, now marking...');

      execFile('./mark-image', [filePath, newEntry.name, newEntry.message, newEntry.strength], function(error, stdout, stderr){
      
        if (error) { // update the db entry with the error 
          markingRef.child(snapshot.key).child('error').set('Error marking image: '+error);
          console.log('Error marking image: '+error);
          return;
        }

        // Pass out stdout for docker log 
        console.log('Marked image.\n'+stdout);
        // Update progress for webapp UI 
        markingRef.child(snapshot.key).child('progress').set('Server completed marking, uploading marked image...');

        execFile('gsutil', ['cp', filePath+'-marked.png', 'gs://watermarking-print-and-scan.appspot.com/marked-images/'+snapshot.key+'/'+timestamp+'/'+newEntry.name+'.png'], function(error, stdout, stderr){
      
          if (error) { // update the db entry with the error 
            markingRef.child(snapshot.key).child('error').set('Error uploading marked image: '+error);
            console.log('Error uploading marked image: '+error);
            return;
          }

          // Pass out stdout for docker log 
          console.log('Uploaded marked image.\n'+stdout);
          // Update progress for webapp UI 
          markingRef.child(snapshot.key).child('markedPath').set("marked-images/" + snapshot.key + "/" + timestamp + "/" + newEntry.name + ".png");

        });

      });

    });

  }
});


