// firebase-admin-singleton.js
// ===========================

var admin = require('firebase-admin');

// Initialize the app with a service account, granting admin privileges
var serviceAccount = require('/keys/WatermarkingPrintAndScan-8705059a4ba1.json');
admin.initializeApp({
	credential: admin.credential.cert(serviceAccount),
	databaseURL: "https://watermarking-print-and-scan.firebaseio.com"
});

module.exports = {

	getAdmin() {
		return admin;
	}

}
