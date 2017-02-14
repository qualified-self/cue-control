#!/bin/sh
rm -rf export
mkdir -p export
ARGS="--force --no-java --export"
processing-java --sketch=BehaviorTreePrototype --output=export/BehaviorTreePrototype.macosx --platform=macosx $ARGS
processing-java --sketch=BehaviorTreePrototype --output=export/BehaviorTreePrototype.linux --platform=linux $ARGS
processing-java --sketch=BehaviorTreePrototype --output=export/BehaviorTreePrototype.windows --platform=windows $ARGS
processing-java --sketch=hsfm_prototype/gui-version/v2/HFSMPrototype --output=export/HFSMPrototype.macosx --platform=macosx $ARGS
processing-java --sketch=hsfm_prototype/gui-version/v2/HFSMPrototype --output=export/HFSMPrototype.linux --platform=linux $ARGS
processing-java --sketch=hsfm_prototype/gui-version/v2/HFSMPrototype --output=export/HFSMPrototype.windows --platform=windows $ARGS

