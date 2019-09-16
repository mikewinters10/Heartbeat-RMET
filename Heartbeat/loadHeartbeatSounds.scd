s.waitForBoot({
a = Buffer.read(s, ~curDir ++ "/Heartbeat/20190124_Heartbeat.wav");

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

				// play the heartbea
				Synth(\playHeartbeat, [\mul, mul]);

				// wait this long
				((1/bpm)*60+rand).wait
			} );
		} );
	} ).play;
};

})

