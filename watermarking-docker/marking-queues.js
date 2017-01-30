// marking-queues.js
// =================

var firebaseAdminSingleton = require('./firebase-admin-singleton');
var firebaseAdmin = firebaseAdminSingleton.getAdmin();

// setup variable for running shell script 
var execFile = require('child_process').execFile;

var Queue = require('firebase-queue');
var queueRef = firebaseAdmin.database().ref('queue');

var tools = require('./tools');

module.exports = {

	setup: function () {

		console.log('Setting up marking queues.');

		/////////////////////////////////////////////////////
		//
		// first marking queue - downloads image 
		// 
		/////////////////////////////////////////////////////

		var downloadForMarkingQueueOptions = {
		  'specId': 'download_for_marking_spec'
		};
		var downloadForMarkingQueue = new Queue(queueRef, downloadForMarkingQueueOptions, function(data, progress, resolve, reject) {
		  
		  console.log('Downloading image named: '+data.name+' for marking, from gcs at location: '+data.path);

		  // create a timestamp so we can store the marked image with a unique path 
		  var timestamp = String(Date.now());
		  var filePath = '/tmp/'+timestamp+'/'+data.name;

		  console.log('Saving file for marking onto the server at location: '+filePath); 

		  // execFile: executes a file with the specified arguments
		  execFile('gsutil', ['cp', 'gs://watermarking-print-and-scan.appspot.com/'+data.path, filePath], function(error, stdout, stderr){

		    if (error) reject(error); 

		    data.filePath = filePath; 
		    data.timestamp = timestamp;
		    data._new_state = 'download_for_marking_spec_finished';
		    resolve(data);

		  });

		});

		/////////////////////////////////////////////////////
		//
		// second marking queue - marks image 
		// 
		/////////////////////////////////////////////////////

		var markImageQueueOptions = {
		  'specId': 'mark_image_spec'
		};
		var markImageQueue = new Queue(queueRef, markImageQueueOptions, function(data, progress, resolve, reject) {
		  
		  console.log('Marking image at location: '+data.filePath+' with message '+data.message+' at strength '+data.strength);

		  execFile('./mark-image', [data.filePath, data.name, data.message, data.strength], function(error, stdout, stderr){
		      
		    if (error) reject(error); 

		    // Pass out stdout for docker log 
		    console.log('Marked image.\n'+stdout);

		    data._new_state = 'mark_image_spec_finished';
		    resolve(data); 

		  });

		});

		/////////////////////////////////////////////////////
		//
		// third marking queue - uploads marked image 
		// 
		/////////////////////////////////////////////////////

		var uploadMarkedImageQueueOptions = {
		  'specId': 'upload_marked_image_spec'
		};
		var uploadMarkedImageQueue = new Queue(queueRef, uploadMarkedImageQueueOptions, function(data, progress, resolve, reject) {
		  
		  console.log("Uploading marked image...");

		  var markedFileGCSPath = 'marked-images/'+data.uid+'/'+data.timestamp+'/'+data.name+'.png';

		  execFile('gsutil', ['cp', data.filePath+'-marked.png', 'gs://watermarking-print-and-scan.appspot.com/'+markedFileGCSPath], function(error, stdout, stderr){
		      
		    if (error) reject(error); 

		    // Pass out stdout for docker log 
		    console.log('Uploaded marked image.\n'+stdout);

		    var updateBDCallback = function(urlString) {
		        // Create a new 'marked' entry 
		        var markedImageRef = firebaseAdmin.database().ref('/original-images/'+data.uid+'/'+data.imageSetKey+'/marked-images/'+data.markedImageKey);
		        markedImageRef.update({
		          message: data.message,
		          name: data.name,
		          path: markedFileGCSPath,
		          strength: data.strength, 
		          servingUrl: urlString
		        });
		        
		        resolve();

		    };

		    tools.getServingUrl(markedFileGCSPath, updateBDCallback);

		  });

		});

	}
}