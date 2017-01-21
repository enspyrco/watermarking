
var https = require('https');

var Queue = require('firebase-queue');
var admin = require('firebase-admin');

// var tools = require('./tools');

// Initialize the app with a service account, granting admin privileges
var serviceAccount = require('/keys/WatermarkingPrintAndScan-8705059a4ba1.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://watermarking-print-and-scan.firebaseio.com"
});

// setup variables for running shell script and reading files 
var sys = require('util');
var execFile = require('child_process').execFile;
var fs = require('fs');

// Setup variables for db access 
// As an admin, the app has access to read and write all data, regardless of Security Rules
var markingRef = admin.database().ref("marking/incomplete");
var incompleteMarkingLogsRef = admin.database().ref("logs/marking/incomplete");

console.log('Setting up listeners...');

// Retrieve new 'marking' entries as they are added to our database 
markingRef.on("child_added", function(snapshot, prevChildKey) {
  var markingEntry = snapshot.val();
  if(markingEntry.path !== null) {

    // check if there has already been an attempt 
    if(markingEntry.attempts > 0) {
      // log the problematic entry 
      console.log("A previous attempt was already made to mark the file "+markingEntry.name);
      console.log("Incomplete marking entry is being removed and logged.");
      incompleteMarkingLogsRef.push(markingEntry);
      // remove the problematic entry 
      markingRef.set(null);
      return;
    }
    
    // increment the attempts 
    markingRef.child(snapshot.key).child('attempts').set(markingEntry.attempts+1); 

    markingRef.child(snapshot.key).child('progress').set('Server has received request and is downloading original image...');

    // create a timestamp so we can store the marked image with a unique path 
    var timestamp = String(Date.now());
    var filePath = '/tmp/'+snapshot.key+'/'+markingEntry.name;

    console.log("Saving file for marking, from gcs at location \'"+markingEntry.path+"\', to \'"+filePath+"\'."); 

    // execFile: executes a file with the specified arguments
    execFile('gsutil', ['cp', 'gs://watermarking-print-and-scan.appspot.com/'+markingEntry.path, filePath], function(error, stdout, stderr){
      
      if (error) { // update the db entry with the error 
        markingRef.child(snapshot.key).child('error').set('Error downloading original image: '+error);
        console.log('Error downloading original image: '+error);
        return;
      }
      
      // Pass out stdout for docker log 
      console.log('Downloaded image.\n'+stdout);
      // Update progress for webapp UI 
      markingRef.child(snapshot.key).child('progress').set('Server downloaded image, now marking...');

      console.log("Marking image with message \'"+markingEntry.message+"\' at strength "+markingEntry.strength); 

      execFile('./mark-image', [filePath, markingEntry.name, markingEntry.message, markingEntry.strength], function(error, stdout, stderr){
      
        if (error) { // update the db entry with the error 
          markingRef.child(snapshot.key).child('error').set('Error marking image: '+error);
          console.log('Error marking image: '+error);
          return;
        }

        // Pass out stdout for docker log 
        console.log('Marked image.\n'+stdout);
        // Update progress for webapp UI 
        markingRef.child(snapshot.key).child('progress').set('Server completed marking, uploading marked image...');

        console.log("Uploading marked image...");

        var markedFileGCSPath = 'marked-images/'+snapshot.key+'/'+timestamp+'/'+markingEntry.name+'.png';

        execFile('gsutil', ['cp', filePath+'-marked.png', 'gs://watermarking-print-and-scan.appspot.com/'+markedFileGCSPath], function(error, stdout, stderr){
      
          if (error) { // update the db entry with the error 
            markingRef.child(snapshot.key).child('error').set('Error uploading marked image: '+error);
            console.log('Error uploading marked image: '+error);
            return;
          }

          // Pass out stdout for docker log 
          console.log('Uploaded marked image.\n'+stdout);
          

          var options = {
            host: 'watermarking-print-and-scan.appspot.com',
            path: '/serving-url?path='+encodeURI(markedFileGCSPath),
            headers: { 'secret': 'zpwmtujdmshwhdkpsjhatrenrpkahwhsngsgnsklaoxmshsgd' }
          };

          callback = function(response) {
          
            var str = '';

            //another chunk of data has been recieved, so append it to `str`
            response.on('data', function (chunk) {
          
              str += chunk;

            });

            //the whole response has been recieved, so we just print it out here
            response.on('end', function () {
              
              console.log("Serving URL was obtained: "+str);

              // change to https and remove newline 
              str = str.replace('http:', 'https:');
              str = str.replace(/\n$/, '');

              // Create a new 'marked' entry 
              var markedImagesRef = admin.database().ref('/original-images/'+snapshot.key+'/'+markingEntry.imageSetKey+'/marked-images/');
              markedImagesRef.push({
                message: markingEntry.message,
                name: markingEntry.name,
                path: "marked-images/" + snapshot.key + "/" + timestamp + "/" + markingEntry.name + ".png",
                strength: markingEntry.strength, 
                servingUrl: str
              });
              
              // Remove the 'marking' entry 
              markingRef.set(null);

            });
          
          };

          https.request(options, callback).end();

        });

      });

    });

  }
});

var detectingRef = admin.database().ref("detecting/incomplete");
var incompleteDetectingLogsRef = admin.database().ref("logs/detecting/incomplete");
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

var queueRef = admin.database().ref('queue');
var queue = new Queue(queueRef, function(data, progress, resolve, reject) {
  
  // Get a reference to the image's db entry 
  var originalImageRef = admin.database().ref("original-images/"+data.uid+"/"+data.imageKey);
  
  console.log("Task added to queue: "+data);

  var options = {
    host: 'watermarking-print-and-scan.appspot.com',
    path: '/serving-url?path='+encodeURI(data.path),
    headers: { 'secret': 'zpwmtujdmshwhdkpsjhatrenrpkahwhsngsgnsklaoxmshsgd' }
  };

  callback = function(response) {
  
    var str = '';

    //another chunk of data has been recieved, so append it to `str`
    response.on('data', function (chunk) {
  
      str += chunk;

    });

    //the whole response has been recieved, so we just print it out here
    response.on('end', function () {
      
      console.log("Serving URL was obtained: "+str);

      // change to https and remove newline 
      str = str.replace('http:', 'https:');
      str = str.replace(/\n$/, '');

      originalImageRef.update({
        'servingUrl': str
      });

      resolve();

    });
  
  };

  https.request(options, callback).end();

});

var verifyUsersQueueOptions = {
  'specId': 'spec_1'
};
var verifyUsersQueue = new Queue(queueRef, verifyUsersQueueOptions, function(data, progress, resolve, reject) {
  
  console.log('Verifying user with id: '+data.uid);

  // Get a reference to the users section of the db 
  var userRef = admin.database().ref("users").child(data.uid);

  // create an entry to indicate user is verified 
  userRef.set({
    name: data.name,
    email: data.email
  });

  // remove the request 
  var requestRef = admin.database().ref("user-requests").child(data.uid);
  requestRef.set(null);

  console.log('Verifed.');

  resolve();

});

console.log('Queue setup finished.');

