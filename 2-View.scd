// View Set-Up

// GLOBALS
~fontSize = 30;
~imageHeight = 220;

// INITIALIZATION
// Different for Mac and Windows
Platform.case(
    \osx,       { ~mainWindow = Window.new("Heartbeats Study", Rect(277, 428, 854, 575) ); },
    \linux,     { "Linux".postln },
	\windows,   { ~mainWindow = Window.new("Heartbeats Study", Rect(450.0, 287.0, 888.0, 578.0) ); }
);

// THe view for the eyes
~eyesView = View(~fixationCrossView, 300@300);

// This is put behind the view.
~centerStaticText = StaticText(~fixationCrossView, 300@300).font_(Font.new(size:(~fontSize * 1))).align_(\center);

// FOUR BUTTONS
~buttonArray = Array.fill(4, {
	Button(~mainWindow)
	.font_( Font.new(size:~fontSize) )
	.visible_(false)
	.action_({arg butt;
		~buttonArrayAction.(butt);
	})
});

// NEXT BUTTON
~nextButton = Button(~mainWindow)
.font_( Font.new(size:~fontSize) )
.string_(" Next > > >")
.enabled_(true)
.action_({
	~nextButtonAction.();
});

// FEELING SLIDER
~feelingSlider = Slider(~mainWindow).visible_(false).orientation_(\horizontal).thumbSize_(25).step_(1/6).value_(0.5).mouseUpAction_({ ~feelingSliderAction.(); });
~feelingSlider.fixedHeight_(40);
~feelingSliderText = StaticText(~mainWindow).visible_(false).align_(\center).font_(Font.new(size:20)).string_("1            2            3            4            5            6            7\n\nNot Well at All                                                Extremely Well");

// RMET Instructions
~rmetInstructions = StaticText(~mainWindow).visible_(true).align_(\center).font_(Font.new(size:~fontSize));

// Participant ID
/*~participantIDTextField =  TextField(~mainWindow).visible_(true).font_(Font.new(size:~fontSize));
~participantIDStaticText =  StaticText(~mainWindow).visible_(true).font_(Font.new(size:~fontSize)).string_("Participant ID: ");*/

// Test Audio
~testAudioButton = Button(~mainWindow)
.font_( Font.new(size:~fontSize) )
.states_([ ["Test Audio",  Color.black, Color.white], ["Done", Color.white, Color.grey] ])
.action_({ if (~initialSound.isPlaying, {~initialSound.stop}, {~initializeLSL.(~participantID); ~initialSound = ~playHeartbeatAtBPM.(80)}) });

// LAYOUT
~rmetLayout = GridLayout.rows(
	[nil, nil, nil], // Instructions
	[~buttonArray[0], nil,~buttonArray[1]],
	[nil, nil, nil], // Manual Margin above the image
	[nil, nil, nil],
	[nil, nil, nil], // Manual Margin below the image
	[~buttonArray[2], nil, ~buttonArray[3]],
	[nil, nil, nil], // Slider
	[nil, ~testAudioButton, ~nextButton]
);

// LAYOUT FINE TUNING
// Column Widths
~rmetLayout.setMinColumnWidth(1,420);    // Minimum width for use of center static text
~rmetLayout.setMinColumnWidth(0, 200);  // Left Buttons
~rmetLayout.setMinColumnWidth(2, 200);  // Right Buttons

// Row heights
~rmetLayout.setMinRowHeight(2, 10).setMinRowHeight(4, 10); // Margins around image
~rmetLayout.setMinRowHeight(3,~imageHeight);       // Height of image (determines size)
~rmetLayout.setMinRowHeight(5,30);         // Slider Height
~rmetLayout.setMinRowHeight(7,90);       // Next button height

// Add additional spanning elements
~rmetLayout.addSpanning(~rmetInstructions, 0, 0, 1, 3);
~rmetLayout.addSpanning(~centerStaticText, 3, 0, 1, 3);
~rmetLayout.addSpanning(~eyesView, 3, 0, 1, 3);
~rmetLayout.addSpanning(~feelingSlider, 5, 1, 1, 1);
~rmetLayout.addSpanning(~feelingSliderText, 6, 0, 1, 3);

// Set the layout..
~mainWindow.layout_(~rmetLayout);

// Push to front
~mainWindow.front;

