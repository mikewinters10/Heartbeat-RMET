// Written in SuperCollider 3.8.0
// By R. Michael Winters
// September 15, 2019
//
// To run the code:
// 1) Select all the text (e.g. command + a)
// 2) Evaluate the code (e.g. command + enter)
//
// Debugging is on by default. It makes the trials shorter for easier testing.
// Note that the photographs are not included because I'm treating them as property of the autism research center.
// You can find them by visiting autismresearchcenter.com.

// What is the participant ID?
~participantID = "Testing";

// Debugging?
~debugging = true;

{
	// Set the current directory
	~curDir = Document.current.dir;

	// Load experiment files (like MVC framework)
	(~curDir +/+ "1-Model.scd").load;
	(~curDir +/+ "2-View.scd").load;
	(~curDir +/+ "3-Controller.scd").load;

	// Load Heartbeat Sound
	(~curDir +/+ "Heartbeat/loadHeartbeatSounds.scd").load;

}.fork(AppClock);

