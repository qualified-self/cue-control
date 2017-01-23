#!/bin/sh
mkdir -p export
processing-java --sketch=BehaviorTreePrototype --output=export/BehaviorTreePrototype.macosx --platform=macosx --force --export
processing-java --sketch=BehaviorTreePrototype --output=export/BehaviorTreePrototype.linux --platform=linux --force --export
processing-java --sketch=BehaviorTreePrototype --output=export/BehaviorTreePrototype.windows --platform=windows --force --export
processing-java --sketch=hsfm_prototype/gui-version/HFSMPrototype --output=export/HFSMPrototype.macosx --platform=macosx --force --export
processing-java --sketch=hsfm_prototype/gui-version/HFSMPrototype --output=export/HFSMPrototype.linux --platform=linux --force --export
processing-java --sketch=hsfm_prototype/gui-version/HFSMPrototype --output=export/HFSMPrototype.windows --platform=windows --force --export

