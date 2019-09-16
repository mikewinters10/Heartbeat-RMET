~affectiveEmpathyPrompt = "I could feel what they were feeling.";
~affectiveEmpathyPrompt = "To what extent did you feel what they were feeling?";
~affectiveEmpathyPrompt = "How well did you feel what they were feeling?";


// Initialize
~enoughTimeHasPast = false;

~buttonArrayAction = { arg butt;

	// Get the time of selection
	~timeOfButtonSelection = Date.getDate.rawSeconds;

	// Retrieve the string from the button
	~buttStr = butt.string;

	// Retrieve the index of the currently selected button
	~buttIdx = ~curWordArray.find([~buttStr]);

	// Put the word in the center
	~centerStaticText.string_(~buttStr);

	// Deselect any buttons that are clicked
	(0..3).removeAll( [~buttIdx] ).do( { |idx| ~buttonArray[idx].value = 0; } );

	// If a button is selected, enable the Next Button
	if  (~buttonIsSelected.() && ~enoughTimeHasPast , {~nextButton.visible_(true)}, {~nextButton.visible_(false)});
};

// Check if a button is selected
~buttonIsSelected = {~buttonArray.collect({|butt| butt.value}).includes(1)};

~feelingSliderAction = {
	~timeSliderWasTouched = Date.getDate.rawSeconds;
	~feelingSliderHasBeenTouched = true;
	if ( ~enoughTimeHasPast, { ~nextButton.visible_(true) });
};

~nextButtonAction = {
	// If we are just starting or if there has been a break.
	if ( (~testAudioButton.visible) || (~centerStaticText.string.contains("Block")), {
		~testAudioButton.visible_(false);
		~initializeRMETView.();
		~initialSound.stop;
	}, {
		if (~buttonArray[1].visible, {
			~initializeFeelingView.();
		}, {
			// Else:
			~writeDataAndContinue.();

			// If we haven't finished
			if ( ~curStimIdx < ~stimuliArray.size, {

				if ( (~curStimIdx > 1) && ((~curStimIdx - 1).mod(~numTrialsPerBlock) == 0), {
					// It's time for a break
					~takeABreakView.();
				}, {
					// If it's not time for a break, and we are not done with the experiment:
					~initializeRMETView.();
				} );
			}, {
				// If we have reached the end of the study
				~finishExperimentView.();
			});
		} );
	});
};

// How to initialize the two views
~initializeRMETView = {
	// Set Trial Variables
	~startTime = Date.getDate;
	~rmetEyesIdx = ~stimuliArray[~curStimIdx][0];
	~eyesVisible = ~stimuliArray[~curStimIdx][1];
	~trialBPM = ~stimuliArray[~curStimIdx][2];
	~sendLSLMarker.( "Trial: " ++ ~curStimIdx.asString );

	// Initialize View
	~buttonArray.do( { | button | button.visible_(true) } );
	~rmetInstructions.string_("What is this person feeling?");
	~centerStaticText.font_(Font.new(size:(~fontSize * 1.7)));
	~feelingSlider.visible_(false);
	~feelingSliderText.visible_(false);
	~polulateButtonsWithWords.(~rmetEyesIdx);
	~eyesView.setBackgroundImage(Image.new(~eyesDir ++ ~rmetEyesIdx.asString), 11);
	~eyesView.visible_(~eyesVisible);
	~nextButton.visible_(false);

	~heartbeatSound = ~playHeartbeatAtBPM.(~trialBPM);
	~whenEnoughTimeHasPastActions.(~minListeningTime);
};

~initializeFeelingView = {
	~feelingViewStartTime = Date.getDate.rawSeconds;
	~nextButton.visible_(false);
	~sendLSLMarker.( "Init. Feeling View");
	~centerStaticText.font_(Font.new(size:(~fontSize * 1)));
	~centerStaticText.string_(~affectiveEmpathyPrompt);
	~rmetInstructions.string_("");
	~buttonArray.do( { | button | button.visible_(false); } );
	~feelingSlider.value_(0.5).visible_(true);
	~feelingSliderText.visible_(true);
	~eyesView.visible_(false);
	~feelingSliderHasBeenTouched = false;
	~whenEnoughTimeHasPastActions.(~minAfterTrialInterval);
};

// POPULATE BUTTONS WITH WORDS
~polulateButtonsWithWords = { arg rmetEyesIdx;
	~centerStaticText.string_("");
	~curWordArray = ~data[rmetEyesIdx][0..3].scramble;
	~buttonArray.do( { | button, idx|
		var curWord = ~curWordArray[idx];
		var definition = ~makeTooltipFromDefinitionOfWord.(curWord);
		button.states = [ [~curWordArray[idx],  Color.black, Color.white], [~curWordArray[idx], Color.white, Color.grey] ];
		button.toolTip_(~makeTooltipFromDefinitionOfWord.( ~curWordArray[idx] ) );
		button.canFocus_(false);
	} );
};

~whenEnoughTimeHasPastActions = { arg timeToWait;
	{// Force a certain amount of time to pass.
		~enoughTimeHasPast = false;
		timeToWait.wait;
		~enoughTimeHasPast = true;

		// Check which event to do (NOTE: minListeningTime should not equal ~minAfterTrialInterval
		if (timeToWait == ~minListeningTime, {
			~heartbeatSound.stop;
			~buttonArray.do( { |button| button.visible_(true); } );
			if  (~buttonIsSelected.(), {
				var timeSinceLastTouch = (Date.getDate.rawSeconds - ~timeOfButtonSelection);
				~nextButton.visible_(true);
				if (timeSinceLastTouch > 10, {~nextButton.doAction() })  });
		});
		if (timeToWait == ~minAfterTrialInterval, {
			//var timeSinceLastTouch = (Date.getDate.rawSeconds - ~timeSliderWasTouched);
			if (~feelingSliderHasBeenTouched, { ~nextButton.visible_(true);  });
		});
	}.fork(AppClock);
};

~writeDataAndContinue = {
	//Write Line
	~writeDataLine.();

	// Advance stimulus idx
	~curStimIdx = ~curStimIdx + 1;
};

// Set the finish experiment view:
~finishExperimentView = {
	~feelingSlider.visible_(false);
	~feelingSliderText.visible_(false);
	~centerStaticText.string_("Thank you for participating.\nPlease knock on the door to signal that you are done!");
	~nextButton.visible_(false);
};

~takeABreakView = {

	~feelingSlider.visible_(false);
	~feelingSliderText.visible_(false);
	~centerStaticText.string_("Block " ++ ~curBlock ++ " of " ++ ~totNumBlocks.asInteger ++ " completed.\nPlease take a short break." ); //++ ~curBlock.asString ++ "/" ~totNumBlocks.asString ++ " completed.\nPlease take a break.");
	~nextButton.visible_(true);
	~nextButton.enabled_(false);
	~sendLSLMarker.("End Block " ++ ~curBlock.asString);

	{
		1.do({
			~interBlockWaitTime.wait;
			~nextButton.enabled_(true);
			~curBlock = ~curBlock + 1;
		});
	}.fork(AppClock);

};

~writeDataLine = {
	var participant = ~participantID.asString;
	var trial = (~curStimIdx).asString; // To make start at 1
	var rmetIdx = (~rmetEyesIdx).asString; // To make start at 1
	var trialBPM = ~trialBPM;
	var soundLength = ~minListeningTime;
	var startTime = ~startTime.asSortableString; // The start time of the trial
	var selectedWord = ~buttStr; // The word they selected
	var timeToSelect = (~timeOfButtonSelection - ~startTime.rawSeconds).round(0.001); // The time it took to select the word
	var startTimeFeelingView = (~feelingViewStartTime - ~startTime.rawSeconds).round(0.001) ; // When did the feeling view (second view) pop up?
	var feelingStrength = (~feelingSlider.value*6 + 1).asString; // Their ratings of "how well they felt what they were feeling"
	var timeToSelectFeeling = (~timeSliderWasTouched - ~feelingViewStartTime).round(0.001); // From the time of the openning of the feeling view, how long to select feeling?
	var endTime = (Date.getDate.rawSeconds - ~startTime.rawSeconds).round(0.001); // What time did the trial end?
	var eyesVisible = ~eyesVisible;
	var writeStr = participant ++ "," ++ trial ++ "," ++ rmetIdx ++ "," ++ trialBPM ++ "," ++ soundLength ++ "," ++ startTime ++ "," ++ selectedWord ++ "," ++ timeToSelect ++ "," ++ startTimeFeelingView ++ "," ++ feelingStrength ++ "," ++ timeToSelectFeeling ++ "," ++ endTime ++ "," ++ ~curWordArray[0] ++ "," ++ ~curWordArray[1]  ++ "," ++ ~curWordArray[2] ++ "," ++ ~curWordArray[3] ++ "," ++ eyesVisible ++ "\n";
	~writeFile = File(~writeFilePath, "a");
	~writeFile.write(writeStr);
	~writeFile.close;
};