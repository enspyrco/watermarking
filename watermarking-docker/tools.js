// tools.js
// ========

var https = require('https');
var twilio = require('twilio');

var twilioAccountSid = 'TWILIO_ACCOUNT_SID_REMOVED'; // Account SID from www.twilio.com/console
var twilioAuthToken = 'TWILIO_AUTH_TOKEN_REMOVED';   // Auth Token from www.twilio.com/console

module.exports = {
  
  getServingUrl: function (path, updateDBCallback) {

  	var options = {
    	host: 'watermarking-print-and-scan.appspot.com',
    	path: '/serving-url?path='+encodeURI(path),
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

	      updateDBCallback(str);

	    });
  
  	};

  	https.request(options, callback).end();
    
  },

  sendSMStoAndrew: function (smsMessage) {

  	var client = new twilio.RestClient(twilioAccountSid, twilioAuthToken);

	client.messages.create({
    	body: smsMessage,
    	to: '+61419373730',  // Text this number
    	from: '+61437738868' // From a valid Twilio number
	}, function(err, message) {
    	console.log(message.sid);
	});
  }

  sendSMStoNick: function (smsMessage) {

  	var client = new twilio.RestClient(twilioAccountSid, twilioAuthToken);

	client.messages.create({
    	body: smsMessage,
    	to: '+61447591141',  // Text this number
    	from: '+61437738868' // From a valid Twilio number
	}, function(err, message) {
    	console.log(message.sid);
	});
  }

};