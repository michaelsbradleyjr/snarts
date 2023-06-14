{.push raises: [].}

import pkg/snarts

type
  DataModel = object
    x: string

  States = enum
    st1, st2

  Events = enum
    evA, evB

  Event = object
    case name: Events
    of evA:
      y: int
    of evB:
      z: string

func init(T: typedesc[DataModel], x: string): T =
  T(x: x)

func init(T: typedesc[DataModel]): T =
  T.init("default")

let # const
  # spec1 = statechart: []
  # spec2 = statechart("snart2"): []
  # spec3 = statechart(States, st1): []
  # spec4 = statechart(DataModel, States, Events, Event, "snart2"): []
  # spec5 = statechart(DataModel, States, Events, Event, "snart2", st1): []

  # state1 = state(States, Events, Event): []

  # spec6 = statechart(DataModel, States, Events, Event, "snart2", st1): [
  #   state1
  # ]

  spec7 = statechart(DataModel, States, Events, Event, "snart2", st1): [
    state(States, Events, Event, []),
    state(States, Events, Event, st1, st2, []),
    state([]),
    parallel([])
  ]

# echo ""
# echo spec1
# echo ""
# echo spec2
# echo ""
# echo spec3
# echo ""
# echo spec4
# echo ""
# echo spec5
# echo ""
# echo state1
# echo ""
# echo spec6
echo ""
echo spec7
echo ""
