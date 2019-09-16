// Boot the server if it's not already booted
s.options.sampleRate = 44100
s.reboot
Server.killAll

// Load in the track
a = Buffer.read(s, Document.current.dir ++ "/20190124_Heartbeat.wav")

// Load functions
(Document.current.dir ++ "/Heartbeat-Functions.scd").load

// Test it
~playHeartbeatAtBPM.(80);

/// RUN EXPERIMENT
(
{
	// Trial Configuration
	var bpmArray = [40, 60, 80, 100, 120];
	var numRepetitions = 5;       // How many repetitions to give each BPM per experiment
	var silenceControl = false;    // Should we include silence trials as a control?
	var numOfTrials = (bpmArray.size + silenceControl.asInteger) * numRepetitions;

	// Stimuli Configuration
	var lengthOfStimuli = 20;  // seconds of stimuli presentation per trial
	var lengthOfSilence = 10;  // seconds of silence in between stimuli trials
	var lengthOfPrep = 30;      // seconds before start of data colleciton

	// Randomize the trialsBPM
	var trialsBPM = ((numOfTrials - silenceControl.asInteger).collect({ |i| bpmArray[i.mod(bpmArray.size)] }) ++ if(silenceControl, {(silenceControl ! numRepetitions)})).scramble;

	// Write to the log
	var lengthOfExperimentInSecs = ~writeLog.(lengthOfStimuli, lengthOfSilence, lengthOfPrep, trialsBPM);

	// Play some preparatory sounds
	~playPrepSounds.(lengthOfPrep);
	//lengthOfPrep.wait;

	// Run the experiment
	trialsBPM.do({ |bpm, idx|

		// Userfeedback
		Date.getDate.asSortableString.postln;
		[(idx+1).asString ++ "/" ++ numOfTrials.asString, bpm.asString ++ " BPM"].postln;
		if ( bpm != true, {
			var task = ~playHeartbeatAtBPM.(bpm).play;
			~oscOut.sendMsg('/OSC-Marker-Stream', bpm);
			lengthOfStimuli.wait;
			task.stop;
			~oscOut.sendMsg('/OSC-Marker-Stream', 'Silence');
			lengthOfSilence.wait;
		}, {
			(lengthOfStimuli + lengthOfSilence).wait;
		});
	});

	// Play the sound at the end of the experiment
	lengthOfExperimentInSecs.wait;
	8.do({|i| fork{ {SinOsc.ar( 200 + (200 * i )) * EnvGen.kr(Env.perc) * 0.1}.play; 0.1.wait; } } );

}.fork(SystemClock); // System clock is the most accurate
)

// Replaced Oct. 6, 2018
// Randomly choose from 120 and 40 BPM
// var trialsBPM = numOfTrials.collect({ |i| if ( i.even, {40}, {120} ) }).scramble;