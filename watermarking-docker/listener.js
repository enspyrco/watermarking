var firebase = require("firebase");

// Initialize the app with a service account, granting admin privileges
firebase.initializeApp({
  databaseURL: "https://watermarking-print-and-scan.firebaseio.com/",
  serviceAccount: "/keys/WatermarkingPrintAndScan-8705059a4ba1.json" // /keys/
});

// setup variables for running shell script 
var sys = require('util');
var exec = require('child_process').exec;
// callback that is run when process terminates 
function markingComplete(error, stdout, stderr) { 
	if (error) {
    console.error(`exec error: ${error}`);
    return;
  }
  console.log(`stdout: ${stdout}`);
  console.log(`stderr: ${stderr}`);

  console.log('process terminated');

  // TODO: upload the marked file here 

  // TODO: remove the database entry for the file to be marked 

}

// As an admin, the app has access to read and write all data, regardless of Security Rules
var db = firebase.database();
var ref = db.ref("marking/incomplete");

// Retrieve new posts as they are added to our database
ref.on("child_added", function(snapshot, prevChildKey) {
  var newEntry = snapshot.val();
  if(newEntry.path !== null) {
  	// console.log("path: " + newEntry.path);
  	// console.log("file: " + newEntry.file);

  	exec("./mark.sh " + newEntry.path + " " + newEntry.name + " " + newEntry.message + " " + newEntry.strength + " " + snapshot.key, markingComplete);
  }
});


