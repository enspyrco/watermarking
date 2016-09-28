var firebase = require("firebase");

// Initialize the app with a service account, granting admin privileges
firebase.initializeApp({
  databaseURL: "https://watermarking-print-and-scan.firebaseio.com/",
  serviceAccount: "/keys/WatermarkingPrintAndScan-8705059a4ba1.json" // /keys/
});

// setup variables for running shell script 
var sys = require('util');
var exec = require('child_process').exec;

// Setup variables for db access 
// As an admin, the app has access to read and write all data, regardless of Security Rules
var db = firebase.database();
var markingRef = db.ref("marking/incomplete");
var markedRef = db.ref("marked-images");

// Retrieve new 'marking' entries as they are added to our database 
markingRef.on("child_added", function(snapshot, prevChildKey) {
  var newEntry = snapshot.val();
  if(newEntry.path !== null) {

    // create a timestamp so we can store the marked image with a unique path 
    var timestamp = String(Date.now());

    // execute the shell script and then set the db entries in the callback 
  	exec("./mark.sh " + newEntry.path + " " + newEntry.name + " " + newEntry.message + " " + newEntry.strength + " " + snapshot.key + " " + timestamp, function (error, stdout, stderr) { 
  
      if (error) { // update the db entry with the error 
        markingRef.child(snapshot.key).child('error').set(error);
        return;
      }

      // create a new db entry for the marked image 
      var newMarkedRef = markedRef.child(snapshot.key).push();

      // set the data for the new db entry and set the 'marking' entry with the key of the 'marked' entry 
      //  this allows the web app lcient to use the 'marking' entry to get a download url for the 'marked' entry 
      newMarkedRef.set({
          name: newEntry.name,
          message: newEntry.message,
          strength: newEntry.strength,
          path: "marked-images/" + snapshot.key + "/" + timestamp + "/" + newEntry.name + ".png"
        },
        function(error) { // callback on completion of set 
          if (error) {
            markingRef.child(snapshot.key).child('error').set(error);
          } else {
            markingRef.child(snapshot.key).child('markedImageKey').set(newMarkedRef.key);
          }
        });

    }); 

  }
});


