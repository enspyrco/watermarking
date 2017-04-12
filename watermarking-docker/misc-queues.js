// misc-queues.js
// ==============

var firebaseAdminSingleton = require('./firebase-admin-singleton');
var firebaseAdmin = firebaseAdminSingleton.getAdmin();

var Queue = require('firebase-queue');
var queueRef = firebaseAdmin.database().ref('queue');

var tools = require('./tools');

module.exports = {

	setup: function () {

		console.log('Setting up miscellaneous queues.');

		var queueRef = firebaseAdmin.database().ref('queue');

		/////////////////////////////////////////////////////
		//
		// get serving url queue - for original image 
		// 
		/////////////////////////////////////////////////////
		var getServingUrlQueueOptions = {
		  'specId': 'get_serving_url_spec',
		  'sanitize': false
		};
		var getServingUrlQueue = new Queue(queueRef, getServingUrlQueueOptions, function(data, progress, resolve, reject) {

		  if(data.hasOwnProperty('_error_details')) { // if we have made a previous attempt and failed 
		    tools.sendSMStoNick('There was an error in getServingUrlQueue.');
		    reject();
		  }

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
		  'specId': 'verify_users_spec',
		  'sanitize': false
		};
		var verifyUsersQueue = new Queue(queueRef, verifyUsersQueueOptions, function(data, progress, resolve, reject) {
		  
		  if(data.hasOwnProperty('_error_details')) { // if we have made a previous attempt and failed 
		    tools.sendSMStoNick('There was an error in verifyUsersQueue.');
		    reject();
		  }

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

		/////////////////////////////////////////////////////
		//
		// notify admin queue - when user requests verification, notify admin via sms 
		// 
		/////////////////////////////////////////////////////
		var notifyAdminOfVerificationRequestOptions = {
		  'specId': 'notify_admin_of_verification_request_spec',
		  'sanitize': false
		};
		var notifyAdminOfVerificationRequestQueue = new Queue(queueRef, notifyAdminOfVerificationRequestOptions, function(data, progress, resolve, reject) {

		  if(data.hasOwnProperty('_error_details')) { // if we have made a previous attempt and failed 
		    tools.sendSMStoNick('There was an error in notifyAdminOfVerificationRequestQueue.');
		    reject();
		  }

		  console.log('Received request to verify user with id: '+data.uid);

		  // Get a reference to the users section of the db 
		  var requestRef = firebaseAdmin.database().ref("user-requests").child(data.uid);

		  // check if a notification has already been sent 
		  requestRef.once("value", function(snapshot) {			

		  	if(!snapshot.val().notified) { // if none has been sent, send it 

		  	  // send the SMS 
			  tools.sendSMStoAndrew('Someone has requested access to the watermarking web app.');

			  // update the entry to indicate notifications has been sent 
			  requestRef.update({notified: true});

			  console.log('An SMS notification has been sent to Andrew.');

			}
			else {
			  console.log('A notification has already been sent.');
			}

			resolve();

		  });

		});
	}
};

