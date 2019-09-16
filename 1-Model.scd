// Set different experiment paramters depending upon whether being used for debugging
if (~debugging, {
	~participantID = "MW";
	~numTrialsPerBlock = 10; // Number of trials between breaks
	~minListeningTime = 3; // seconds of listening to condition (i.e. Slow, Fast, Silence)
	~minAfterTrialInterval = 1; // time between entering "Feeling View" and next trial
	~interBlockWaitTime = 1; // seconds before the user can go to the next block (mandatory rest time).
}, {
	~numTrialsPerBlock = 12; // Number of trials between breaks
	~minListeningTime = 20; // seconds of listening to condition (i.e. Slow, Fast, Silence)
	~minAfterTrialInterval = 10; // time between entering "Feeling View" and next trial
	~interBlockWaitTime = 15; // seconds before the user can go to the next block (mandatory rest time).
});

// Load data from the RMET Answers (36 eyes)
~data = CSVFileReader.read(~curDir +/+ "Model/RMET-Answers.csv", true, true);

// List the conditions:
~conditions = ["Silence", 40, 140, "NoEyes"]; // Numbers are the heartbeat BPM associated with visual eyes.


// Associate each of the three conditions with each of the sets of eyes
~rmetEyesIdx = ((1..~data.size) ! ~conditions.size).flatten;

// Randomly associate each of the three conditions with each set of eyes.
~audioConditionArray = nil ! (~data.size * ~conditions.size); // Initialize Array of audio conditions
~visualConditionArray = true ! (~data.size * ~conditions.size); // Initialize Array of visual conditions (1 means there will be eyes)
~noEyesConditionArray = ( (~conditions[1] ! ( ~data.size / 2 ) ) ++ (~conditions[2] ! ( ~data.size / 2 ) ) ).scramble; // The choices when there are no eyes, scrambled but equal "slow" and "fast"

~data.size.do( { |i|
	var randConditions = ~conditions.scramble; // Randomize the ordering of the conditions
	randConditions.do({ | condition, j|
		var idx = i + (~data.size * j);
		if ( condition == "NoEyes", {
			~audioConditionArray[ idx ] = ~noEyesConditionArray[ i ];
			~visualConditionArray[ idx ] = false; // Meaning no eyes
		}, {
			~audioConditionArray[ idx ] = condition;
		});
	});
});

// Associate the eyes with the conditions
x = Array.fill( ( ~data.size * ~conditions.size ), { |i|
	// format: [ Which eye index, Are there eyes showing?, What is the sound? ]
	[~rmetEyesIdx[i], ~visualConditionArray[i], ~audioConditionArray[i] ];
});


// Scramble each set of 36.
~stimuliArray = [];
~conditions.size.do({ |i|
	// Scramble each set of 36
	var scrambledRMETOrdering = (x[ ( 36 * i ) .. ( ( 36 * ( i + 1 ) ) - 1 ) ]).scramble;
	~stimuliArray = ~stimuliArray ++ scrambledRMETOrdering ;
});

// Add practice
~practice = ["jealous", "panicked", "arrogant", "hateful"];
~data = [~practice] ++ ~data;
~stimuliArray = [  [0, true, ~conditions[2]] ] ++ ~stimuliArray;

// Always start at the beginning
~curStimIdx = 0;

// Separate experiment into blocks
~totNumBlocks = ((~stimuliArray.size - 1) / ~numTrialsPerBlock).roundUp.asInteger;
~curBlock = 1;

// Writing data
~writeFilePath = ( ~curDir +/+ "ExpData" +/+ Date.getDate.asSortableString ++ "_p" ++ ~participantID.asString ++ ".csv");

// Write the column headings
~writeColumnHeadings = {
	var str = "Participant ID, Trial, RMET Idx, Trial BPM, Sound Length (s), Start Time (s), Selected Word, Time to Select (s), Start Time Feeling View (s), Feeling Strength, Time To Select Feeling (s), End Time (s), UL Button, UR Button, LL Button, LR Button, Eyes Visible\n";
	~writeFile = File(~writeFilePath, "a");
	~writeFile.write(str);
	~writeFile.close;
}.();


// Set the network address for LSL communication
~lsl = NetAddr.new("127.0.0.1", 7110);    // create the NetAddr

// Initialize LSL Initialize the Network Address for LSL Markers
~initializeLSL = { arg participantID;
	{
		1.do({
			~lsl.sendMsg("/OSC-Marker-Stream", Date.getDate.asString);
			0.05.wait;
			~lsl.sendMsg("/OSC-Marker-Stream", "Participant: " ++ participantID);
			0.05.wait;
			~lsl.sendMsg("/OSC-Marker-Stream", "Number of Trials: " ++ (~stimuliArray.size - ~practice.flop.size));
			0.05.wait;
			~lsl.sendMsg("/OSC-Marker-Stream", "Stimuli Presentation (s): " ++ ~minListeningTime);
			0.05.wait;
			~lsl.sendMsg("/OSC-Marker-Stream", "Post-Trial Silence (s): " ++ ~minAfterTrialInterval);
		})
	}.fork(SystemClock)
};

// Initialize it now
~initializeLSL.(~participantID);

// Send LSLMarker (for sending the trials)
~sendLSLMarker = { arg marker;
	var delayTime = 0.045; // The markers sent to the amplifier should be delayed by a few tens of ms to be perfectly aligned with the audio.
	{
		1.do({
			delayTime.wait;
			~lsl.sendMsg("/OSC-Marker-Stream", marker);
			marker.postln;
		})
	}.fork(SystemClock);
};

// RMET DEFINITIONS
// Load Dictionary and Extract Word Array
~rmetDictionary = CSVFileReader.read(~curDir +/+ "Model/RMET-Definitions.csv", true, true);
~wordArray = ~rmetDictionary.flop[0];


// A function for finding the index of the word in the dictionary.
~returnIndexinWordArray = {arg word;
	var wordIdx = nil;
	for ( 0, (~wordArray.size - 1), { arg i;
		if ( ~wordArray[ i ] == word.toUpper,
			{ wordIdx = i; },
		);
	});
	wordIdx
};

// Make a tooltip string from the definition of a word.
~makeTooltipFromDefinitionOfWord = { arg word;
	var idx = ~returnIndexinWordArray.(word);
	var definition = ~rmetDictionary[idx][1..];
	var tooltip = definition[0] ++ ";\n" ++ definition[1];
	tooltip
};

// Set eyesDirectory
~eyesDir = ~curDir +/+ "Eyes/"