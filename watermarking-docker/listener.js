var firebase = require("firebase");

// Initialize the app with a service account, granting admin privileges
firebase.initializeApp({
  databaseURL: "https://watermarking-print-and-scan.firebaseio.com/",
  serviceAccount: "/keys/WatermarkingPrintAndScan-8705059a4ba1.json" 
});

// setup variables for running shell script and reading files 
var sys = require('util');
var execFile = require('child_process').execFile;
var fs = require('fs');

// Setup variables for db access 
// As an admin, the app has access to read and write all data, regardless of Security Rules
var db = firebase.database();
var markingRef = db.ref("marking/incomplete");

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

var detectionRef = db.ref("detecting/incomplete");
// Retrieve new 'detect' entries as they are added to our database 
detectionRef.on("child_added", function(snapshot, prevChildKey) {
  var newEntry = snapshot.val();
  if(newEntry.originalPath !== null) {

    detectionRef.child(snapshot.key).child('progress').set('Server has received request and is downloading images...');

    var originalPath = '/tmp/'+snapshot.key+'/original';
    var markedPath = '/tmp/'+snapshot.key+'/marked';

    // execFile: executes a file with the specified arguments
    execFile('gsutil', ['cp', 'gs://watermarking-print-and-scan.appspot.com/'+newEntry.pathOriginal, originalPath], function(error, stdout, stderr){
      
      if (error) { // update the db entry with the error 
        detectionRef.child(snapshot.key).child('error').set('Error downloading original image: '+error);
        console.log('Error downloading original image: '+error);
        return;
      }
      
      // Pass out stdout for docker log 
      console.log('Downloaded original image.\n'+stdout);
      // Update progress for webapp UI 
      detectionRef.child(snapshot.key).child('progress').set('Server downloaded original image, now downloading marked image...');

      execFile('gsutil', ['cp', 'gs://watermarking-print-and-scan.appspot.com/'+newEntry.pathMarked, markedPath], function(error, stdout, stderr){
      
        if (error) { // update the db entry with the error 
          detectionRef.child(snapshot.key).child('error').set('Error downloading marked image: '+error);
          console.log('Error downloading marked image: '+error);
          return;
        }

        // Pass out stdout for docker log 
        console.log('Downloaded marked image.\n'+stdout);
        // Update progress for webapp UI 
        detectionRef.child(snapshot.key).child('progress').set('Server downloaded images, detecting watermark...');

        execFile('./detect-wm', [snapshot.key, originalPath, markedPath], function(error, stdout, stderr){
    
          if (error) { // update the db entry with the error 
            detectionRef.child(snapshot.key).child('error').set('Error detecting watermark: '+error);
            console.log('Error detecting watermark: '+error);
            return;
          }

          // Read in the output.json file 
          var resultsJson = JSON.parse(fs.readFileSync('/tmp/'+snapshot.key+'.json', 'utf8'));

          // Pass out stdout for docker log 
          console.log('Detected watermark.\n'+stdout);
          // Update progress for webapp UI 
          detectionRef.child(snapshot.key).child('results').set(resultsJson);
          

        });

      });

    });

  }
});


