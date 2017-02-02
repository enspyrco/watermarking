// detection-queues.js
// =================== 

var firebaseAdminSingleton = require('./firebase-admin-singleton');
var firebaseAdmin = firebaseAdminSingleton.getAdmin();

// setup variables for running shell script and accessing file system 
var execFile = require('child_process').execFile;
var fs = require('fs');

var Queue = require('firebase-queue');
var queueRef = firebaseAdmin.database().ref('queue');

var tools = require('./tools');

var detectingRef = firebaseAdmin.database().ref("detecting/incomplete");

module.exports = {

	setup: function () {

		console.log('Setting up detection queues...');

		/////////////////////////////////////////////////////
		//
		// first detection queue - download original image 
		// 
		/////////////////////////////////////////////////////

		var downloadOriginalQueueOptions = {
		  'specId': 'download_original_spec'
		};
		var downloadOriginalQueue = new Queue(queueRef, downloadOriginalQueueOptions, function(data, progress, resolve, reject) {
		  
			var originalPath = '/tmp/'+data.uid+'/original';

			console.log('Downloading original image file for detection, from gcs at location '+data.pathOriginal+', to '+originalPath); 

			// Update progress for webapp UI 
      		detectingRef.child(data.uid).child('progress').set('Server has received request, downloading original image from storage...');

			// download with gsutil 
    		execFile('gsutil', ['cp', 'gs://watermarking-print-and-scan.appspot.com/'+data.pathOriginal, originalPath], function(error, stdout, stderr){
      
      			if (error) reject(error); 
      			
      			console.log('Downloaded original image.');
  				
  				// Update progress for webapp UI 
      			detectingRef.child(data.uid).child('progress').set('Server downloaded original image, now downloading marked image from storage...');

      			// add data to task that is required for next step and resolve 
      			data.originalPath = originalPath;
		  		data._new_state = 'download_original_spec_finished';
		  		resolve(data);

		  	});

		});

		/////////////////////////////////////////////////////
		//
		// second detection queue - download marked image 
		// 
		/////////////////////////////////////////////////////

		var downloadMarkedQueueOptions = {
		  'specId': 'download_marked_spec'
		};
		var downloadMarkedQueue = new Queue(queueRef, downloadMarkedQueueOptions, function(data, progress, resolve, reject) {
		  
			var markedPath = '/tmp/'+data.uid+'/marked';

			console.log('Saving marked image file for detection, from gcs at location '+data.pathMarked+', to '+markedPath);

			execFile('gsutil', ['cp', 'gs://watermarking-print-and-scan.appspot.com/'+data.pathMarked, markedPath], function(error, stdout, stderr){
      
        		if (error) reject(error); 

        		console.log('Downloaded marked image.');
        
        		// Update progress for webapp UI 
        		detectingRef.child(data.uid).child('progress').set('Server has downloaded both images, now detecting watermarks...');

        		// add data to task that is required for next step and resolve 
      			data.markedPath = markedPath;
		  		data._new_state = 'download_marked_spec_finished';
		  		resolve(data);

		  	});

		});

		/////////////////////////////////////////////////////
		//
		// third detection queue - performs detection 
		// 
		/////////////////////////////////////////////////////

		var performDetectionQueueOptions = {
		  'specId': 'perform_detection_spec'
		};
		var performDetectionQueue = new Queue(queueRef, performDetectionQueueOptions, function(data, progress, resolve, reject) {
		  
		  	console.log('Detecting message...');

		  	execFile('./detect-wm', [data.uid, data.originalPath, data.markedPath], function(error, stdout, stderr){
    
	          	if (error) reject(error); 

	       	}).on('exit', code => {

	       		console.log('final exit code is', code);

	       		if(code == 254) {

	       			console.log('Error - the marked and original images were of different sizes.')
	       			// Update progress for webapp UI 
	          		detectingRef.child(data.uid).child('progress').set('Detection unsuccessful.');
	          		detectingRef.child(data.uid).child('isDetecting').set(false);
	          		detectingRef.child(data.uid).child('error').set('Different sizes for marked and original images');

	       			reject('Error - different sizes for marked and original images.'); 
	       		}
	       		else if(code == 0) {

	       			// Read in the output.json file 
	          		var resultsJson = JSON.parse(fs.readFileSync('/tmp/'+data.uid+'.json', 'utf8'));

	          		console.log('Detected watermark.');
	          
		          	// Update progress for webapp UI 
		          	detectingRef.child(data.uid).child('progress').set('Detection complete.');
		          	detectingRef.child(data.uid).child('isDetecting').set(false);
		          	detectingRef.child(data.uid).child('results').set(resultsJson);
		          
		          	console.log('Message detected and results saved to database.');

		          	resolve();

	       		}
	       		

	       	});

		});

	}
};