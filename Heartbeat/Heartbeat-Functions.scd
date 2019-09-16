s.waitForBoot({

	SynthDef(\playHeartbeat, { arg mul;
		var env = EnvGen.kr(Env.linen(attackTime: 0.01, sustainTime: 1, releaseTime:0.01));
		var playBuf = PlayBuf.ar(2, a, doneAction: 2) * env * 0.5;
		Out.ar(0, playBuf ! 2)
	}).send(s);

	~playHeartbeatAtBPM = { arg bpm;
		Task( {
			if (bpm > 0, {
				inf.do( {
					var randAmount = 40 / bpm;
					var rand = 0.gauss(0.08 * randAmount); // gaussian centered at 0 with standard deviation of 0.02
					var mul = 0.8 + (rand * 10 / randAmount); // the amplitude value

					// play the heartbeat
					Synth(\playHeartbeat, [\mul, mul]);

					// wait this long
					((1/bpm)*60+rand).wait
				} );
			} );
		} ).play;
	};

	~writeLog = { arg lengthOfStimuli, lengthOfSilence, lengthOfPrep, trialsBPM;
		var numOfTrials = trialsBPM.size;
		var pathName = (Document.current.dir ++ "/Logs/" ++ Date.getDate.asSortableString);
		var lengthOfExperimentInSeconds = (numOfTrials * (lengthOfStimuli + lengthOfSilence) + lengthOfPrep );

		// User feedback
		("Trials BPMs: " ++ trialsBPM.asString).postln;
		("Length of Exp.: " ++ (lengthOfExperimentInSeconds/60).round(0.01).asString ++ " minutes").postln;
		("Length of Prep.: " ++ lengthOfPrep.asString ++ " seconds").postln;

		f = File.new((Document.current.dir ++ "/Logs/" ++ Date.getDate.asSortableString ++ ".txt"), "w");
		s = (
			Date.getDate.asSortableString ++ "\n\n" ++
			"Number of Trials: " ++ numOfTrials ++ "\n" ++
			"Length of Stimuli: " ++ lengthOfStimuli ++ "\n" ++
			"Length of Silence: "++ lengthOfSilence ++ "\n" ++
			"Length of Silence at Beginning: " ++ lengthOfPrep ++ "\n\n"
			"Trials BPMs: " ++ trialsBPM
		);
		f.write( s.asString);
		f.close;

		// return the lengthOfExperiment
		lengthOfExperimentInSeconds;
	};


	~playPrepSounds = { arg lenOfPrep;
		if (lenOfPrep > 0, {
			var waitTime = ( lenOfPrep / 4 );
			4.do( { |i|
				{ SinOsc.ar(200 + (200*i), mul: 0.02) * EnvGen.kr(Env.perc) ! 2}.play;
				((lenOfPrep - (i * waitTime)).asString ++ " seconds to start").postln;
				waitTime.wait;
			});
		});
	};
})
