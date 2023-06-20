{.push raises: [].}

import pkg/snarts

type
  States = enum
    st1, st2, st3

  Events = enum
    evA, evB

  Data = object
    case id: States
    else:
      discard

  Event = object
    case name: Events
    else:
      discard

# move/adapt the following code to tests
# ------------------------------------------------------------------------------

let # const
  state1 = state(States, Events, Data, Event, st1, st2): []

  spec1 = statechart(States, Events, Data, Event, "snart1", st1, [])

  spec2 = statechart(States, Events, Data, Event, "snart1", st1, @[])

  spec3 = statechart(States, Events, Data, Event, "snart1", st1): []

  spec4 = statechart(States, Events, Data, Event, "snart1", st1): @[]

  spec5 = statechart(States, Events, Data, Event, "snart1", st1): [
    state1
  ]

  spec6 = statechart(States, Events, Data, Event, "snart1", st1): [
    state1,
    state(States, Events, Data, Event, st1, st2, []),
    state1
  ]

  spec7 = statechart(States, Events, Data, Event, "snart1", st1): [
    state1,
    state(st1, st2, []),
    state1
  ]

echo ""
echo state1
echo ""
echo spec1.St
echo spec1.Ev
echo spec1.Dm
echo spec1.Em
echo ""
echo spec1
echo ""
echo spec2
echo ""
echo spec3
echo ""
echo spec4
echo ""
echo spec5
echo ""
echo spec6
echo ""
echo spec7

echo ""

# when the pieces are in place, snart1 example should consist of the following
# ------------------------------------------------------------------------------
# import pkg/snarts
#
# type
#   States = enum
#     inactive, active
#
#   Events = enum
#     toggle
#
#   Data = object
#     id: States
#
#   Event = object
#     name: Events
#
# const
#   spec = statechart(
#     States, Events, Data, Event,
#     id = "toggle1",
#     initial = inactive
#   ):[
#       state(active, [
#         transition(toggle, inactive)
#       ]),
#       state(inactive, [
#         transition(toggle, active)
#       ])
#   ]
#
#   machine = spec.compile
#
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
