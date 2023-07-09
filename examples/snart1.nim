{.push raises: [].}

import pkg/snarts

type
  States = enum
    inactive, active

  Events = enum
    toggle

  Data = object
    id: States

  Event = object
    name: Events

const # or: let
  spec = statechart(
    States, Events, Data, Event,
    name = "snart1",
    initial = inactive,
    state(
      id = active,
      transition(
        event = toggle,
        target = inactive,
        exe = block:
          debugEcho config
    )),
    state(
      id = inactive,
      transition(
        event = toggle,
        target = active,
        exe = block:
          debugEcho config
  )))

  machine = spec.compile.expect

# get rid of the echos
echo ""
echo spec
echo ""
echo machine

let actor = machine.start.expect

# get rid of the echos
echo ""
echo actor[]
echo ""

# actor.send Event(name: toggle)
# => {inactive}
#
# actor.send Event(name: toggle)
# => {active}

actor.stop.expect
