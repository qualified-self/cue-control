// BaseNode simpleTest() {
//   return new ParallelNode().setDecorator(new ChronoDecorator(5))
//             .addChild(new ConstantNode(State.SUCCESS))
//             .addChild(new ConstantNode(State.SUCCESS));
// }

// BaseNode createTreeOtherSelfTest() {
//   return new SequentialNode()
//     .addChild(new BlackboardSetNode("sync", "false"))
//     .addChild(new BlackboardSetNode("end", "false"))
//     .addChild(new BlackboardSetNode("sync_start_time", "new Date().getTime() / 1000.0"))
//     .addChild(new BlackboardSetNode("sync_current_time", "0"))
//
//     //     Configurations (intensity, duration, rate) of the STROBE are activated randomly at semi-regular intervals
//     .addChild(new ParallelNode().setDecorator(new WhileDecorator("!$end"))
//
//       // Update timers.
//       .addChild(new SequentialNode().setDecorator(new WhileDecorator("!$end"))
//         .addChild(new BlackboardSetNode("sync_current_time", "new Date().getTime()/1000.0 - ${sync_start_time}"))
//         .addChild(new BlackboardSetNode("end", "$sync || ${sync_current_time} > 180"))
//       )
//
//       // Update sync.
//       .addChild(new SelectorNode(true).setDecorator(new WhileDecorator("!$end"))
//         // Is it already sync?
//         .addChild(new ConstantNode(State.SUCCESS).setDecorator(new GuardDecorator("$sync")))
//         // If not, trail whether we have raw_sync > 0.5 for at least 10 seconds
//         .addChild(new SequentialNode().setDecorator(new ChronoDecorator(10))
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
  return new SequentialNode()
    .addChild(new SequentialNode("PROLOGUE: install subject; when ready dim lights off and press 'G' to start").setExpanded(false)
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

    .addChild(new SequentialNode("INTRO (3 minutes)")
      .addChild(new BlackboardSetNode("start_time", "$seconds"))

      .addChild(new OscSendNode("/audio/clip/soundscape/play"))

      // Add one firefly.
//      .addChild(new OscSendNode("/environment/firefly/add"))
      .addChild(new BlackboardSetNode("n_fireflies", 1))
      .addChild(new OscSendNode("/environment/firefly/state-wander")) // let it wander around

      .addChild(new SequentialNode("crossfade audio").setExpanded(false)
        .addChild(new ParallelNode()
          .addChild(new BlackboardRampNode("crossfade", 0, 1, ONE_MINUTE/2))
          .addChild(new BlackboardRampNode("crossfade_prologue", 0.65, 0, ONE_MINUTE/2))
          .addChild(new SequentialNode().setDecorator(new WhileDecorator("$crossfade < 1"))
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
      .addChild(new SequentialNode("introduce single agent").setExpanded(false)
        .addChild(new ParallelNode()
          .addChild(new BlackboardRampNode("crossfade", 0, 1, 30))
          .addChild(new BlackboardRampNode("crossfade_divider", 10, 5, 30))
          .addChild(new SequentialNode().setDecorator(new WhileDecorator("$crossfade < 1"))
            .addChild(new OscSendNode("/audio/beat/gain", "$crossfade"))
            .addChild(new OscSendNode("/environment/firefly/intensity", "$crossfade"))
            .addChild(new OscSendNode("/environment/firefly/period", "$ecg_gap / 1000.0 * Math.round($crossfade_divider)"))
          )
        )
      )

      // Wait for this phase to end
		  .addChild(new ConstantNode(State.SUCCESS).setDecorator(new WhileDecorator("$seconds - $start_time < " + 3*ONE_MINUTE)))
    )

    .addChild(new SequentialNode("ASYNCHRONY (3 minutes)")
      .addChild(new OscSendNode("/environment/firefly/de-phase-all"))
      .addChild(new BlackboardSetNode("start_time", "$seconds"))

      // Start adding agents.
      .addChild(new ParallelNode()
        .addChild(new ParallelNode("reveal fireflies")
          .addChild(new BlackboardRampNode("crossfade", 0, 1, ONE_MINUTE))
          .addChild(new BlackboardRampNode("crossfade_soundscape", 1, 0.65, ONE_MINUTE/3))
          .addChild(new SequentialNode().setDecorator(new WhileDecorator("$crossfade < 1"))
            .addChild(new OscSendNode("/audio/beat/gain", "$crossfade"))
            .addChild(new OscSendNode("/audio/clip/soundscape/gain", "$crossfade_soundscape"))
//            .addChild(new OscSendNode("/environment/firefly/intensity", "$crossfade"))
          )
        )

        .addChild(new SequentialNode("add fireflies").setDecorator(new WhileDecorator("$n_fireflies < " + N_FIREFLIES))
          .addChild(new OscSendNode("/environment/firefly/add"))
          .addChild(new BlackboardSetNode("n_fireflies", "${n_fireflies} + 1"))
          .addChild(new DelayNode(0.1))
        )
      )

      // Wait for this phase to end
		  .addChild(new ConstantNode(State.SUCCESS).setDecorator(new WhileDecorator("$seconds - $start_time < " + 3*ONE_MINUTE)))
    )

    .addChild(new SequentialNode("SYNCHRONY (3 minutes)")
      .addChild(new OscSendNode("/environment/firefly/flash-adjust", "0.05"))
      .addChild(new BlackboardSetNode("start_time", "$seconds"))
      .addChild(new OscSendNode("/environment/firefly/state-ring", ""))

      // Reduce the soundscape to give space to heartbeats
      .addChild(new ParallelNode("heighten fireflies")
        .addChild(new BlackboardRampNode("crossfade", 1, 1.5, ONE_MINUTE/3))
        .addChild(new BlackboardRampNode("crossfade_soundscape", 0.45, ONE_MINUTE/3))
        .addChild(new SequentialNode().setDecorator(new WhileDecorator("$crossfade < 1.5"))
          .addChild(new OscSendNode("/audio/beat/gain", "$crossfade"))
          .addChild(new OscSendNode("/audio/clip/soundscape/gain", "$crossfade_soundscape"))
        )
      )

      // Move the fireflies towards center + to match user's heartbeat
      .addChild(new SequentialNode("fireflies synchronize with heart").setDecorator(new WhileDecorator("$seconds - $start_time < " + 3*ONE_MINUTE))
        .addChild(new BlackboardSetNode("period", "(1 - ${alpha_period})*$period + ${alpha_period} * ($ecg_gap / 1000.0)"))
        // TODO: crossfade to person's heart
        .addChild(new OscSendNode("/environment/firefly/period", "$period"))
      )
    )

    .addChild(new SequentialNode("OUTRO")
        // TODO: dephase more progressively
        .addChild(new OscSendNode("/environment/firefly/flash-adjust", "0.0"))
        .addChild(new OscSendNode("/environment/firefly/de-phase-all"))
        .addChild(new OscSendNode("/environment/firefly/state-wander"))
        .addChild(new DelayNode(20))

        .addChild(new SequentialNode("remove fireflies").setDecorator(new WhileDecorator("$n_fireflies > 1"))
          .addChild(new OscSendNode("/environment/firefly/remove"))
          .addChild(new BlackboardSetNode("n_fireflies", "${n_fireflies} - 1"))
          .addChild(new DelayNode(0.01))
        )

        .addChild(new OscSendNode("/audio/beat/gain", "1.0"))
        .addChild(new DelayNode(15))

        .addChild(new SequentialNode("fade out").setExpanded(false)
          .addChild(new ParallelNode()
            .addChild(new BlackboardRampNode("crossfade", 1, 0, 5.0))
            .addChild(new BlackboardRampNode("crossfade_soundscape", 0, 5.0))
            .addChild(new SequentialNode().setDecorator(new WhileDecorator("$crossfade > 0"))
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
  return new SequentialNode()
    // // SUBJECT sits down and SUPERVISOR hooks him/her up with the system
    .addChild(new SequentialNode("init")
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

    .addChild(new SequentialNode("Intro")
      .addChild(new OscSendNode("/speaker/enable", "1"))
      .addChild(new BlackboardSetNode("amplitude", 0))
      .addChild(new BlackboardSetNode("start_time", "new Date().getTime() / 1000.0"))
      // Intro (runs for approximately 1 minute)
      .addChild(new SequentialNode("Intro loop").setDecorator(new ChronoDecorator(ONE_MINUTE))
        .addChild(new BlackboardSetNode("current_time", "new Date().getTime()/1000.0 - ${start_time}"))
        .addChild(new BlackboardSetNode("amplitude", "${current_time} / " + ONE_MINUTE))
      //     Amplitude of AMBIENT sound increases
        .addChild(new OscSendNode("/speaker/amp/1", "$amplitude"))
      //     VIBROPIXEL amplitude increases at the same time (subtle)
        .addChild(new OscSendNode("/aura/amp/0", "$amplitude * 0.5"))
      )
    )

    // The self appears: runs for 1 minute, then stop when either (1) the subject's SENSOR input is in synch (*) with the BEAT or (2) when we have reached a timeout (3 minutes)
    .addChild(new SequentialNode("The self appears")
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
        .addChild(new SequentialNode().setDecorator(new WhileDecorator("!$end"))
          .addChild(new BlackboardSetNode("current_time", "new Date().getTime()/1000.0 - ${start_time}"))
          .addChild(new BlackboardSetNode("end", "$sync || ${current_time} > " + 3*ONE_MINUTE))
        )

        // Update sync.
        .addChild(new SelectorNode(true).setDecorator(new WhileDecorator("!$end"))
          // Is it already sync?
          .addChild(new ConstantNode(State.SUCCESS).setDecorator(new GuardDecorator("$sync")))
          // If not, trail whether we have raw_sync > 0.5 for at least 10 seconds
          .addChild(new SequentialNode()
            .addChild(new BlackboardSetNode("sync_start_time", "new Date().getTime() / 1000.0"))
            .addChild(new BlackboardSetNode("sync_current_time", "0"))
            .addChild(new SequentialNode().setDecorator(new WhileDecorator("$sync_current_time < " + ONE_MINUTE))
              .addChild(new BlackboardSetNode("sync_current_time", "new Date().getTime()/1000.0 - ${sync_start_time}"))
              .addChild(new ConstantNode(State.SUCCESS).setDecorator(new GuardDecorator("$raw_sync > 0.5")))
            )
            .addChild(new BlackboardSetNode("sync", "true"))
          )
          // Otherwise: sync is false
          .addChild(new BlackboardSetNode("sync", "false"))
        )

        .addChild(new SequentialNode().setDecorator(new WhileDecorator("!$end"))

          // Random configs.
          .addChild(new ProbabilityNode()
            .addChild(new SequentialNode("config 1")
              .addChild(new OscSendNode("/dmx/intensity", "1"))
              .addChild(new OscSendNode("/dmx/duration", "0.1"))
              .addChild(new OscSendNode("/dmx/rate", "0.1"))
            )
            .addChild(new SequentialNode("config 2")
              .addChild(new OscSendNode("/dmx/intensity", "1"))
              .addChild(new OscSendNode("/dmx/duration", "0.5"))
              .addChild(new OscSendNode("/dmx/rate", "0.5"))
            )
            .addChild(new SequentialNode("config 3")
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
    .addChild(new SequentialNode("Synchrony")
      .addChild(new BlackboardSetNode("amplitude", 0))
      .addChild(new BlackboardSetNode("start_time", "new Date().getTime() / 1000.0"))
      .addChild(new SequentialNode("Synchrony loop").setDecorator(new ChronoDecorator(ONE_MINUTE))
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
    .addChild(new SequentialNode("Outro")
      //     Sounds fade out quickly
      .addChild(new BlackboardSetNode("amplitude", 1))
      .addChild(new BlackboardSetNode("start_time", "new Date().getTime() / 1000.0"))
      .addChild(new SequentialNode("Outro loop: Sounds fade out quickly").setDecorator(new ChronoDecorator(ONE_MINUTE/2))
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
	return new SequentialNode()
		.addChild(new BlackboardSetNode("counter", "0"))
		.addChild(new BlackboardSetNode("sensor", "0"))
		.addChild(new BlackboardSetNode("test", "3.5"))
		.addChild(new SelectorNode(true).setDecorator(new WhileDecorator("$counter < 100"))
			.addChild(new SequentialNode().setDecorator(new GuardDecorator("$spacebar"))
//				.addChild(new TextNode("Sensor value: $sensor"))
				.addChild(new BlackboardSetNode("counter", "$counter+1"))
			)
//			.addChild(new OscReceiveNode("/bitalino/0", "sensor", State.FAILURE, 5))
			.addChild(new SequentialNode()
				.addChild(new OscSendNode("/test/string", "\"${test}string\"+$test"))
				.addChild(new OscSendNode("/test/boolean", "false"))
				.addChild(new OscSendNode("/test/int", "10"))
				.addChild(new OscSendNode("/test/real", "${test}*3"))
			)
		);
}

BaseNode createTreePoetry() {
	return new SequentialNode()
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
	return new SequentialNode("main program")
		.addChild(new SequentialNode("initialize").setExpanded(false)
			.addChild(new SequentialNode("switch everything off (initialize devices)")
				.addChild(new OscSendNode("/aura/amp/0",     "0"))
				.addChild(new OscSendNode("/speaker/amp/0",  "0"))
				.addChild(new OscSendNode("/dmx/intensity",  "0"))
				.addChild(new OscSendNode("/dmx/duration",   "0"))
				.addChild(new OscSendNode("/dmx/rate",       "0"))
			)
			.addChild(new OscSendNode("/speaker/enable", "1"))
			.addChild(new SequentialNode("initialize blackboard")
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
			.addChild(new SequentialNode("main loop")
				.addChild(new SequentialNode("introduction").setDecorator(new ChronoDecorator(30))
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
		.addChild(new SequentialNode("switch everything off").setExpanded(false)
			.addChild(new OscSendNode("/speaker/enable", "0"))
			.addChild(new OscSendNode("/aura/amp/0",     "0"))
			.addChild(new OscSendNode("/speaker/amp/0",  "0"))
			.addChild(new OscSendNode("/dmx/intensity",  "0"))
			.addChild(new OscSendNode("/dmx/duration",   "0"))
			.addChild(new OscSendNode("/dmx/rate",       "0"))
		)
		;
}

BaseNode createTree() {
	// return new SelectorNode("try to get + update variable / otherwise succeed", false).setDecorator(new WhileDecorator(new NotCondition(new KeyCondition(' '))))
	//   .addChild(new SequentialNode()
	// 	  .addChild(new OscReceiveNode("/VARIABLE", "var", State.FAILURE, 5))
	// 	  .addChild(new BlackboardSetNode("var", "[var] + 10"))
	//   )
	//   .addChild(new ConstantNode(State.SUCCESS));
	// return new SequentialNode()
	// 			   .addChild(new BlackboardSetNode("var", "0"))
	// 				 .addChild(new ParallelNode().setDecorator(new WhileDecorator(new NotCondition(new KeyCondition(' '))))
	// 				   .addChild(new BlackboardSetNode("var", "0").setDecorator(new GuardDecorator("[var] > 10000", true)))
	// 			     .addChild(new OscSendNode("/variable", "[var]"))
	// 					 .addChild(new SelectorNode("try to get + update variable / otherwise succeed", false)
	// 					   .addChild(new SequentialNode()
	//   					   .addChild(new OscReceiveNode("/VARIABLE", "var", State.FAILURE, 1))
	// 							 .addChild(new BlackboardSetNode("var", "[var] + 10"))
	// 						 )
	// 						 .addChild(new ConstantNode(State.SUCCESS))
	// 					 )
	// 				 );
	return new SequentialNode("Wait for starting cue then launch")
							.addChild(new BlackboardSetNode("end", "0"))
							.addChild(new BlackboardSetNode("counter", "0"))
							.addChild(new BlackboardSetNode("invented", "1000"))
							.addChild(new ProbabilityNode("random event")
								.addChild(1, new BlackboardSetNode("start", "1"))
								.addChild(99, new BlackboardSetNode("start", "0"))
							)
							.addChild(new ConstantNode(State.SUCCESS).setDecorator(new WhileDecorator(new NotCondition(new KeyCondition('G')))))
							.addChild(new SoundCueNode("123go.mp3"))
							.addChild(new ParallelNode("Start the show", true, true)
								.addChild(new SequentialNode("Stuff running in background").setDecorator(new WhileDecorator(new ExpressionCondition("[end] == 0")))
									.addChild(new OscReceiveNode("/cue-proto/start", "start", State.SUCCESS))
									.addChild(new OscReceiveNode("/cue-proto/level", "level", State.SUCCESS))
									.addChild(new BlackboardSetNode("counter", "$counter+1"))
									.addChild(new BlackboardSetNode("volume", "(math.sin( [$ounter * 0.01 ) + 1) / 2"))
								)
								.addChild(new SequentialNode("Start the show")
									.addChild(new OscSendNode("/curtain/on", "1"))
									.addChild(new OscSendNode("/lights/on", "1"))
									.addChild(new OscSendNode("/test/start", "$start * 2"))
									.addChild(new SelectorNode(false)
										.addChild(new OscSendNode("/show/start", 0, 1)
																.setDecorator(new GuardDecorator(new ExpressionCondition("$start == 1"))))
										.addChild(new ParallelNode("Error: try again using emergency procedure")
											.addChild(new SoundCueNode("error.mp3"))
											.addChild(new OscSendNode("/show/startagain", 0, 1))
											)
										)
									.addChild(new ConstantNode(State.SUCCESS).setDecorator(new WhileDecorator(new NotCondition(new KeyCondition('S')))))
									.addChild(new ParallelNode("Stop the show")
										.addChild(new SoundCueNode("stop.mp3"))
										.addChild(new OscSendNode("/curtain/on", "0", 1, 1))
										.addChild(new OscSendNode("/lights/on", "0", 0, 1))
										)
									.addChild(new BlackboardSetNode("end", "1"))
									)
								);
}
