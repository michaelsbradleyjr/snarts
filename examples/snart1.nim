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
    # id = "snart1",
    # initial = inactive
    "snart1",
    inactive
  ):[
    state(active, [
      # transition(toggle, inactive)
    ]),
    state(inactive, [
      # transition(toggle, active)
    ])
  ]

  # machine = spec.compile

echo ""
echo spec
echo ""

# let actor = machine.start
#
# actor.send Event(name: toggle)
#
# echo actor.config
# => {active}
#
# actor.send Event(name: toggle)
#
# echo actor.config
# => {inactive}
#
# actor.stop
