// firebase-admin-singleton.js
// ===========================

var admin = require('firebase-admin');

// Initialize the app with a service account, granting admin privileges
var serviceAccount = require('./keys/firebase-service-account.json');
admin.initializeApp({
	credential: admin.credential.cert(serviceAccount),
});

// Initialize Firestore
var db = admin.firestore();

module.exports = {
	getAdmin() {
		return admin;
	},

	getFirestore() {
		return db;
	}
};
