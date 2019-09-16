s.options.sampleRate = 48000
Server.killAll
s.reboot

(
// What is the participant ID?
~participantID = "2-11";

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
)

