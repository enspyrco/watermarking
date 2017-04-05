
var markingQueues = require('./marking-queues');
var detectionQueues = require('./detection-queues');
var miscQueues = require('./misc-queues');

console.log('Setting up queues...');

markingQueues.setup(); 
detectionQueues.setup();
miscQueues.setup();

console.log('Queue setup finished.');

