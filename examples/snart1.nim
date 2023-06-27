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
    "snart1",
    initial = inactive
  ):[
    # state(active, [
    #   transition(toggle, inactive)
    # ]),
    # state(inactive, [
    #   transition(toggle, active)
    # ])

    # make it compile during refactor
    state(),
    state()
  ]

  machine = spec.compile.expect("failure not expected")

echo ""
echo spec
echo ""
echo machine

let actor = machine.start.expect("failure not expected")

echo ""
echo actor[]
echo ""

# !! demo with transition exe that debugEchos config instead of echoing
#    actor.config
# ---------------------------------------------------------------------
# actor.send Event(name: toggle)
#
# echo actor.config
# => {active}
#
# actor.send Event(name: toggle)
#
# echo actor.config
# => {inactive}

actor.stop.expect("failure not expected")
