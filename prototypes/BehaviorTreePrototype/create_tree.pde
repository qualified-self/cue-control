BaseNode createTree() {
	return new SequenceNode("Wait for starting cue then launch")
							.addChild(new BlackboardSetNode("end", "0"))
							.addChild(new BlackboardSetNode("counter", "0"))
							.addChild(new BlackboardSetNode("invented", "1000"))
							.addChild(new ProbabilityNode("random event")
								.addChild(70, new BlackboardSetNode("start", "1"))
								.addChild(30, new BlackboardSetNode("start", "0"))
							);
						}
		// BaseNode simpleTest() {
//   return new ParallelNode().setDecorator(new ChronoDecorator(5))
//             .addChild(new ConstantNode(State.SUCCESS))
//             .addChild(new ConstantNode(State.SUCCESS));
// }

// BaseNode createTreeOtherSelfTest() {
//   return new SequenceNode()
//     .addChild(new BlackboardSetNode("sync", "false"))
//     .addChild(new BlackboardSetNode("end", "false"))
//     .addChild(new BlackboardSetNode("sync_start_time", "new Date().getTime() / 1000.0"))
//     .addChild(new BlackboardSetNode("sync_current_time", "0"))
//
//     //     Configurations (intensity, duration, rate) of the STROBE are activated randomly at semi-regular intervals
//     .addChild(new ParallelNode().setDecorator(new WhileDecorator("!$end"))
//
//       // Update timers.
//       .addChild(new SequenceNode().setDecorator(new WhileDecorator("!$end"))
//         .addChild(new BlackboardSetNode("sync_current_time", "new Date().getTime()/1000.0 - ${sync_start_time}"))
//         .addChild(new BlackboardSetNode("end", "$sync || ${sync_current_time} > 180"))
//       )
//
//       // Update sync.
//       .addChild(new SelectorNode(true).setDecorator(new WhileDecorator("!$end"))
//         // Is it already sync?
//         .addChild(new ConstantNode(State.SUCCESS).setDecorator(new GuardDecorator("$sync")))
//         // If not, trail whether we have raw_sync > 0.5 for at least 10 seconds
//         .addChild(new SequenceNode().setDecorator(new ChronoDecorator(10))
//           .addChild(new ConstantNode(State.SUCCESS).setDecorator(new GuardDecorator("$raw_sync > 0.5")))
//           .addChild(new BlackboardSetNode("sync", "true"))
//         )
//         // Otherwise: sync is false
//         .addChild(new BlackboardSetNode("sync", "false"))
//       )
//       );
// }

final int N_FIREFLIES = 100;
BaseNode createTreeCepheids() {
  return new SequenceNode()
    .addChild(new SequenceNode("PROLOGUE: install subject; when ready dim lights off and press 'G' to start").setExpanded(false)
      .addChild(new BlackboardSetNode("n_fireflies", 0))
      .addChild(new BlackboardSetNode("period", 10.0))
      .addChild(new BlackboardSetNode("alpha_period", 0.001))
      .addChild(new OscSendNode("/reset"))
      .addChild(new OscSendNode("/environment/firefly/flash-adjust", "0.005"))
      .addChild(new OscSendNode("/environment/firefly/period", "$period"))
      .addChild(new OscSendNode("/audio/clip/prologue/play"))
      .addChild(new OscSendNode("/audio/beat/gain",            "0.0"))
      .addChild(new OscSendNode("/audio/clip/soundscape/gain", "0.0"))
      .addChild(new OscSendNode("/audio/clip/prologue/gain",   "0.65"))
      .addChild(new OscSendNode("/environment/firefly/state-ring")) // this is just so that the first agent goes towards center
    )

    // Wait for a trigger from supervisor: press 'G'
		.addChild(new ConstantNode(State.SUCCESS).setDecorator(new WhileDecorator(new NotCondition(new KeyCondition('G')))))

    .addChild(new SequenceNode("INTRO (3 minutes)")
      .addChild(new BlackboardSetNode("start_time", "$seconds"))

      .addChild(new OscSendNode("/audio/clip/soundscape/play"))

      // Add one firefly.
//      .addChild(new OscSendNode("/environment/firefly/add"))
      .addChild(new BlackboardSetNode("n_fireflies", 1))
      .addChild(new OscSendNode("/environment/firefly/state-wander")) // let it wander around

      .addChild(new SequenceNode("crossfade audio").setExpanded(false)
        .addChild(new ParallelNode()
          .addChild(new BlackboardRampNode("crossfade", 0, 1, ONE_MINUTE/2))
          .addChild(new BlackboardRampNode("crossfade_prologue", 0.65, 0, ONE_MINUTE/2))
          .addChild(new SequenceNode().setDecorator(new WhileDecorator("$crossfade < 1"))
            .addChild(new OscSendNode("/audio/clip/soundscape/gain", "$crossfade"))
            .addChild(new OscSendNode("/audio/clip/prologue/gain", "$crossfade_prologue"))
            .addChild(new OscSendNode("/audio/beat/gain", "$crossfade"))
            .addChild(new OscSendNode("/environment/firefly/intensity", "$crossfade"))
          )
        )
        .addChild(new OscSendNode("/audio/beat/gain", "1.0"))
        .addChild(new OscSendNode("/audio/clip/soundscape/gain", "1.0"))
        .addChild(new OscSendNode("/audio/clip/prologue/gain", "0.0"))
        .addChild(new OscSendNode("/audio/clip/prologue/stop"))
      )

      // One firefly: period increases
      .addChild(new SequenceNode("introduce single agent").setExpanded(false)
        .addChild(new ParallelNode()
          .addChild(new BlackboardRampNode("crossfade", 0, 1, 30))
          .addChild(new BlackboardRampNode("crossfade_divider", 10, 5, 30))
          .addChild(new SequenceNode().setDecorator(new WhileDecorator("$crossfade < 1"))
            .addChild(new OscSendNode("/audio/beat/gain", "$crossfade"))
            .addChild(new OscSendNode("/environment/firefly/intensity", "$crossfade"))
            .addChild(new OscSendNode("/environment/firefly/period", "$ecg_gap / 1000.0 * Math.round($crossfade_divider)"))
          )
        )
      )

      // Wait for this phase to end
		  .addChild(new ConstantNode(State.SUCCESS).setDecorator(new WhileDecorator("$seconds - $start_time < " + 3*ONE_MINUTE)))
    )

    .addChild(new SequenceNode("ASYNCHRONY (3 minutes)")
      .addChild(new OscSendNode("/environment/firefly/de-phase-all"))
      .addChild(new BlackboardSetNode("start_time", "$seconds"))

      // Start adding agents.
      .addChild(new ParallelNode()
        .addChild(new ParallelNode("reveal fireflies")
          .addChild(new BlackboardRampNode("crossfade", 0, 1, ONE_MINUTE))
          .addChild(new BlackboardRampNode("crossfade_soundscape", 1, 0.65, ONE_MINUTE/3))
          .addChild(new SequenceNode().setDecorator(new WhileDecorator("$crossfade < 1"))
            .addChild(new OscSendNode("/audio/beat/gain", "$crossfade"))
            .addChild(new OscSendNode("/audio/clip/soundscape/gain", "$crossfade_soundscape"))
//            .addChild(new OscSendNode("/environment/firefly/intensity", "$crossfade"))
          )
        )

        .addChild(new SequenceNode("add fireflies").setDecorator(new WhileDecorator("$n_fireflies < " + N_FIREFLIES))
          .addChild(new OscSendNode("/environment/firefly/add"))
          .addChild(new BlackboardSetNode("n_fireflies", "${n_fireflies} + 1"))
          .addChild(new DelayNode(0.1))
        )
      )

      // Wait for this phase to end
		  .addChild(new ConstantNode(State.SUCCESS).setDecorator(new WhileDecorator("$seconds - $start_time < " + 3*ONE_MINUTE)))
    )

    .addChild(new SequenceNode("SYNCHRONY (3 minutes)")
      .addChild(new OscSendNode("/environment/firefly/flash-adjust", "0.05"))
      .addChild(new BlackboardSetNode("start_time", "$seconds"))
      .addChild(new OscSendNode("/environment/firefly/state-ring", ""))

      // Reduce the soundscape to give space to heartbeats
      .addChild(new ParallelNode("heighten fireflies")
        .addChild(new BlackboardRampNode("crossfade", 1, 1.5, ONE_MINUTE/3))
        .addChild(new BlackboardRampNode("crossfade_soundscape", 0.45, ONE_MINUTE/3))
        .addChild(new SequenceNode().setDecorator(new WhileDecorator("$crossfade < 1.5"))
          .addChild(new OscSendNode("/audio/beat/gain", "$crossfade"))
          .addChild(new OscSendNode("/audio/clip/soundscape/gain", "$crossfade_soundscape"))
        )
      )

      // Move the fireflies towards center + to match user's heartbeat
      .addChild(new SequenceNode("fireflies synchronize with heart").setDecorator(new WhileDecorator("$seconds - $start_time < " + 3*ONE_MINUTE))
        .addChild(new BlackboardSetNode("period", "(1 - ${alpha_period})*$period + ${alpha_period} * ($ecg_gap / 1000.0)"))
        // TODO: crossfade to person's heart
        .addChild(new OscSendNode("/environment/firefly/period", "$period"))
      )
    )

    .addChild(new SequenceNode("OUTRO")
        // TODO: dephase more progressively
        .addChild(new OscSendNode("/environment/firefly/flash-adjust", "0.0"))
        .addChild(new OscSendNode("/environment/firefly/de-phase-all"))
        .addChild(new OscSendNode("/environment/firefly/state-wander"))
        .addChild(new DelayNode(20))

        .addChild(new SequenceNode("remove fireflies").setDecorator(new WhileDecorator("$n_fireflies > 1"))
          .addChild(new OscSendNode("/environment/firefly/remove"))
          .addChild(new BlackboardSetNode("n_fireflies", "${n_fireflies} - 1"))
          .addChild(new DelayNode(0.01))
        )

        .addChild(new OscSendNode("/audio/beat/gain", "1.0"))
        .addChild(new DelayNode(15))

        .addChild(new SequenceNode("fade out").setExpanded(false)
          .addChild(new ParallelNode()
            .addChild(new BlackboardRampNode("crossfade", 1, 0, 5.0))
            .addChild(new BlackboardRampNode("crossfade_soundscape", 0, 5.0))
            .addChild(new SequenceNode().setDecorator(new WhileDecorator("$crossfade > 0"))
              .addChild(new OscSendNode("/audio/clip/soundscape/gain", "$crossfade_soundscape"))
              .addChild(new OscSendNode("/audio/beat/gain", "$crossfade"))
              .addChild(new OscSendNode("/environment/firefly/intensity", "$crossfade"))
            )
          )
          .addChild(new OscSendNode("/audio/beat/gain", "0.0"))
          .addChild(new OscSendNode("/audio/clip/soundscape/gain", "0.0"))
          .addChild(new OscSendNode("/audio/clip/soundscape/stop"))
          .addChild(new OscSendNode("/environment/firefly/intensity", "0.0"))
        )
        .addChild(new OscSendNode("/environment/firefly/remove"))

        .addChild(new OscSendNode("/reset"))
        .addChild(new OscSendNode("/audio/master/gain", "0.0"))
      )
  ;
}

//final float ONE_MINUTE = 15.0;
//final float ONE_MINUTE = 60.0;
final float ONE_MINUTE = 20.0;
BaseNode createTreeOtherSelf() {
  return new SequenceNode()
    // // SUBJECT sits down and SUPERVISOR hooks him/her up with the system
    .addChild(new SequenceNode("init")
      .addChild(new OscSendNode("/speaker/enable", "0"))
      .addChild(new OscSendNode("/dmx/intensity", "0"))
      .addChild(new OscSendNode("/dmx/enable", "0"))
      .addChild(new OscSendNode("/speaker/amp/0", "0"))
      .addChild(new OscSendNode("/speaker/amp/1", "0"))
      .addChild(new OscSendNode("/aura/amp/0", "0"))
      .addChild(new BlackboardSetNode("raw_sync", "0"))
    )

    // Wait for a trigger from SUPERVISOR
		.addChild(new ConstantNode(State.SUCCESS).setDecorator(new WhileDecorator(new NotCondition(new KeyCondition('G')))))

    .addChild(new SequenceNode("Intro")
      .addChild(new OscSendNode("/speaker/enable", "1"))
      .addChild(new BlackboardSetNode("amplitude", 0))
      .addChild(new BlackboardSetNode("start_time", "new Date().getTime() / 1000.0"))
      // Intro (runs for approximately 1 minute)
      .addChild(new SequenceNode("Intro loop").setDecorator(new ChronoDecorator(ONE_MINUTE))
        .addChild(new BlackboardSetNode("current_time", "new Date().getTime()/1000.0 - ${start_time}"))
        .addChild(new BlackboardSetNode("amplitude", "${current_time} / " + ONE_MINUTE))
      //     Amplitude of AMBIENT sound increases
        .addChild(new OscSendNode("/speaker/amp/1", "$amplitude"))
      //     VIBROPIXEL amplitude increases at the same time (subtle)
        .addChild(new OscSendNode("/aura/amp/0", "$amplitude * 0.5"))
      )
    )

    // The self appears: runs for 1 minute, then stop when either (1) the subject's SENSOR input is in synch (*) with the BEAT or (2) when we have reached a timeout (3 minutes)
    .addChild(new SequenceNode("The self appears")
      .addChild(new BlackboardSetNode("start_time", "new Date().getTime() / 1000.0"))
      .addChild(new BlackboardSetNode("current_time", "0"))
      .addChild(new BlackboardSetNode("sync", "false"))
      .addChild(new BlackboardSetNode("end", "false"))
      //     Everything stops
      .addChild(new OscSendNode("/speaker/amp/1", "0"))
      .addChild(new OscSendNode("/aura/amp/0", "0"))
      //     BEAT sound starts
      .addChild(new OscSendNode("/speaker/amp/0", "0.5"))
      .addChild(new OscSendNode("/dmx/enable", "1"))

      //     Configurations (intensity, duration, rate) of the STROBE are activated randomly at semi-regular intervals
      .addChild(new ParallelNode("main loop").setDecorator(new WhileDecorator("!$end"))

        // Update timers.
        .addChild(new SequenceNode().setDecorator(new WhileDecorator("!$end"))
          .addChild(new BlackboardSetNode("current_time", "new Date().getTime()/1000.0 - ${start_time}"))
          .addChild(new BlackboardSetNode("end", "$sync || ${current_time} > " + 3*ONE_MINUTE))
        )

        // Update sync.
        .addChild(new SelectorNode(true).setDecorator(new WhileDecorator("!$end"))
          // Is it already sync?
          .addChild(new ConstantNode(State.SUCCESS).setDecorator(new GuardDecorator("$sync")))
          // If not, trail whether we have raw_sync > 0.5 for at least 10 seconds
          .addChild(new SequenceNode()
            .addChild(new BlackboardSetNode("sync_start_time", "new Date().getTime() / 1000.0"))
            .addChild(new BlackboardSetNode("sync_current_time", "0"))
            .addChild(new SequenceNode().setDecorator(new WhileDecorator("$sync_current_time < " + ONE_MINUTE))
              .addChild(new BlackboardSetNode("sync_current_time", "new Date().getTime()/1000.0 - ${sync_start_time}"))
              .addChild(new ConstantNode(State.SUCCESS).setDecorator(new GuardDecorator("$raw_sync > 0.5")))
            )
            .addChild(new BlackboardSetNode("sync", "true"))
          )
          // Otherwise: sync is false
          .addChild(new BlackboardSetNode("sync", "false"))
        )

        .addChild(new SequenceNode().setDecorator(new WhileDecorator("!$end"))

          // Random configs.
          .addChild(new ProbabilityNode()
            .addChild(new SequenceNode("config 1")
              .addChild(new OscSendNode("/dmx/intensity", "1"))
              .addChild(new OscSendNode("/dmx/duration", "0.1"))
              .addChild(new OscSendNode("/dmx/rate", "0.1"))
            )
            .addChild(new SequenceNode("config 2")
              .addChild(new OscSendNode("/dmx/intensity", "1"))
              .addChild(new OscSendNode("/dmx/duration", "0.5"))
              .addChild(new OscSendNode("/dmx/rate", "0.5"))
            )
            .addChild(new SequenceNode("config 3")
              .addChild(new OscSendNode("/dmx/intensity", "0.3"))
              .addChild(new OscSendNode("/dmx/duration", "0.1"))
              .addChild(new OscSendNode("/dmx/rate", "0.1"))
            )
          )

          // // TODO: delay should be variable not fixed
          .addChild(new DelayNode(ONE_MINUTE))
        )
      )
    )


    // Synchrony (1 minute)
    .addChild(new SequenceNode("Synchrony")
      .addChild(new BlackboardSetNode("amplitude", 0))
      .addChild(new BlackboardSetNode("start_time", "new Date().getTime() / 1000.0"))
      .addChild(new SequenceNode("Synchrony loop").setDecorator(new ChronoDecorator(ONE_MINUTE))
        .addChild(new BlackboardSetNode("current_time", "new Date().getTime()/1000.0 - ${start_time}"))
        .addChild(new BlackboardSetNode("amplitude", "${current_time} / " + ONE_MINUTE))
      // AMBIENT sound returns
        .addChild(new OscSendNode("/speaker/amp/1", "$amplitude*2"))
      // BEAT sound increases
        .addChild(new OscSendNode("/speaker/amp/0", "0.5+$amplitude"))
      // VIBROPIXEL increases
        .addChild(new OscSendNode("/aura/amp/0", "$amplitude"))
      )
    )

    // Outro (30 seconds)
    .addChild(new SequenceNode("Outro")
      //     Sounds fade out quickly
      .addChild(new BlackboardSetNode("amplitude", 1))
      .addChild(new BlackboardSetNode("start_time", "new Date().getTime() / 1000.0"))
      .addChild(new SequenceNode("Outro loop: Sounds fade out quickly").setDecorator(new ChronoDecorator(ONE_MINUTE/2))
        .addChild(new BlackboardSetNode("current_time", "new Date().getTime()/1000.0 - ${start_time}"))
        .addChild(new BlackboardSetNode("amplitude", "1 - ${current_time} / " + ONE_MINUTE/2))
      // AMBIENT sound returns
        .addChild(new OscSendNode("/speaker/amp/1", "$amplitude"))
      // BEAT sound increases
        .addChild(new OscSendNode("/speaker/amp/0", "$amplitude"))
      // VIBROPIXEL increases
        .addChild(new OscSendNode("/aura/amp/0", "$amplitude"))
      )
    )

    // The end (everything over)
    .addChild(new OscSendNode("/speaker/enable", "0"))
    .addChild(new OscSendNode("/dmx/intensity", "0"))
    .addChild(new OscSendNode("/dmx/enable", "0"))
    .addChild(new TextNode("THE END"))

    ;

}

BaseNode testBitalinoReceive() {
	return new SequenceNode()
		.addChild(new BlackboardSetNode("counter", "0"))
		.addChild(new BlackboardSetNode("sensor", "0"))
		.addChild(new BlackboardSetNode("test", "3.5"))
		.addChild(new SelectorNode(true).setDecorator(new WhileDecorator("$counter < 100"))
			.addChild(new SequenceNode().setDecorator(new GuardDecorator("$spacebar"))
//				.addChild(new TextNode("Sensor value: $sensor"))
				.addChild(new BlackboardSetNode("counter", "$counter+1"))
			)
//			.addChild(new OscReceiveNode("/bitalino/0", "sensor", State.FAILURE, 5))
			.addChild(new SequenceNode()
				.addChild(new OscSendNode("/test/string", "\"${test}string\"+$test"))
				.addChild(new OscSendNode("/test/boolean", "false"))
				.addChild(new OscSendNode("/test/int", "10"))
				.addChild(new OscSendNode("/test/real", "${test}*3"))
			)
		);
}

BaseNode createTreePoetry() {
	return new SequenceNode()
		.addChild(new TextNode("Ô vie"))
		.addChild(new DelayNode(2))
		.addChild(new TextNode("souffle ton"))
		.addChild(new ProbabilityNode()
			.addChild(70, new TextNode("souffle"))
			.addChild(20, new TextNode("pays"))
			.addChild(10, new TextNode("silence"))
		)
		.addChild(new TextNode("dans"))
		.addChild(new ProbabilityNode()
			.addChild(70, new TextNode("le chant"))
			.addChild(20, new TextNode("le vertige"))
			.addChild(10, new TextNode("chaque vibration"))
		)
		.addChild(new ProbabilityNode()
			.addChild(new TextNode("du sôleil"))
			.addChild(new TextNode("de nôs cerveaux"))
			.addChild(new TextNode("de nôs pensées"))
			.addChild(new TextNode("de tes constellations"))
		)
		;
}


BaseNode createTreeOct25() {
	return new SequenceNode("main program")
		.addChild(new SequenceNode("initialize").setExpanded(false)
			.addChild(new SequenceNode("switch everything off (initialize devices)")
				.addChild(new OscSendNode("/aura/amp/0",     "0"))
				.addChild(new OscSendNode("/speaker/amp/0",  "0"))
				.addChild(new OscSendNode("/dmx/intensity",  "0"))
				.addChild(new OscSendNode("/dmx/duration",   "0"))
				.addChild(new OscSendNode("/dmx/rate",       "0"))
			)
			.addChild(new OscSendNode("/speaker/enable", "1"))
			.addChild(new SequenceNode("initialize blackboard")
				.addChild(new BlackboardSetNode("counter",       "0"))
				.addChild(new BlackboardSetNode("end",           "0"))
				.addChild(new BlackboardSetNode("pulse_0",       "0"))
				.addChild(new BlackboardSetNode("ambient_sound", "0"))
				.addChild(new BlackboardSetNode("amplitude",     "0.5"))
				.addChild(new BlackboardSetNode("strobe_0_intensity", "0"))
				.addChild(new BlackboardSetNode("strobe_0_duration",  "0"))
				.addChild(new BlackboardSetNode("strobe_0_rate",      "0.5"))
			)
		)

		.addChild(new ConstantNode(State.SUCCESS).setDecorator(new WhileDecorator(new NotCondition(new KeyCondition('G')))))

		.addChild(new ParallelNode()
			.addChild(new ParallelNode("osc controls").setDecorator(new WhileDecorator("[end] == 0"))
				.addChild(new OscSendNode("/aura/amp/0",     "[pulse_0]*127"))
				.addChild(new OscSendNode("/speaker/amp/0",  "[ambient_sound]*255"))
				.addChild(new OscSendNode("/dmx/intensity",  "[strobe_0_intensity]*255"))
				.addChild(new OscSendNode("/dmx/duration",   "[strobe_0_duration]*255"))
				.addChild(new OscSendNode("/dmx/rate",       "[strobe_0_rate]*255"))
			)
			.addChild(new SequenceNode("main loop")
				.addChild(new SequenceNode("introduction").setDecorator(new ChronoDecorator(30))
					//.addChild(new OscReceiveNode("/sensor/value", "amplitude", State.SUCCESS))
					.addChild(new BlackboardSetNode("counter", "[counter]+1"))
//					.addChild(new BlackboardSetNode("amplitude", "[counter]*0.0005"))
					.addChild(new BlackboardSetNode("amplitude", "(math.sin( [counter] * 0.01 ) + 1) / 2"))
					.addChild(new BlackboardSetNode("pulse_0",       "[amplitude]"))
					.addChild(new BlackboardSetNode("ambient_sound", "[amplitude]"))
				)
				.addChild(new BlackboardSetNode("end",           "1"))
			)
		)
		.addChild(new SequenceNode("switch everything off").setExpanded(false)
			.addChild(new OscSendNode("/speaker/enable", "0"))
			.addChild(new OscSendNode("/aura/amp/0",     "0"))
			.addChild(new OscSendNode("/speaker/amp/0",  "0"))
			.addChild(new OscSendNode("/dmx/intensity",  "0"))
			.addChild(new OscSendNode("/dmx/duration",   "0"))
			.addChild(new OscSendNode("/dmx/rate",       "0"))
		)
		;
}
