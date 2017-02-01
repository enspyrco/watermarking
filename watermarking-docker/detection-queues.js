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

			// download with gsutil 
    		execFile('gsutil', ['cp', 'gs://watermarking-print-and-scan.appspot.com/'+data.pathOriginal, originalPath], function(error, stdout, stderr){
      
      			if (error) reject(error); 
      			
      			console.log('Downloaded original image.');
  				
  				// Update progress for webapp UI 
      			detectingRef.child(snapshot.key).child('progress').set('Server downloaded original image, now downloading marked image...');

		  // console.log('Downloading image named: '+data.name+' for marking, from gcs at location: '+data.path);

		  // // create a timestamp so we can store the marked image with a unique path 
		  // var timestamp = String(Date.now());
		  // var filePath = '/tmp/'+timestamp+'/'+data.name;

		  // console.log('Saving file for marking onto the server at location: '+filePath); 

		  // // execFile: executes a file with the specified arguments
		  // execFile('gsutil', ['cp', 'gs://watermarking-print-and-scan.appspot.com/'+data.path, filePath], function(error, stdout, stderr){

		  //   if (error) reject(error); 

		  //   data.filePath = filePath; 
		  //   data.timestamp = timestamp;
		  //   data._new_state = 'download_for_marking_spec_finished';
		  //   resolve(data);

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
		  
			var markedPath = '/tmp/'+snapshot.key+'/marked';

			console.log('Saving marked image file for detection, from gcs at location '+data.pathMarked+', to '+markedPath);

		  // console.log('Marking image at location: '+data.filePath+' with message '+data.message+' at strength '+data.strength);

		  // execFile('./mark-image', [data.filePath, data.name, data.message, data.strength], function(error, stdout, stderr){
		      
		  //   if (error) reject(error); 

		  //   // Pass out stdout for docker log 
		  //   console.log('Marked image.\n'+stdout);

		  //   data._new_state = 'mark_image_spec_finished';
		  //   resolve(data); 

		  // });

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
};