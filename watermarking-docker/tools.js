// tools.js
// ========

var https = require('https');

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
  bar: function () {
    // whatever
  }
};