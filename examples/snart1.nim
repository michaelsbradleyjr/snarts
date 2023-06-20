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

# new stuff
# ------------------------------------------------------------------------------

let # const
  spec1 = statechart(States, Events, Data, Event,
    st1, "snart1", [])

  spec2 = statechart(States, Events, Data, Event,
    st1, "snart1", @[])

  spec3 = statechart(States, Events, Data, Event,
    st1, "snart1"): []

  spec4 = statechart(States, Events, Data, Event,
    st1, "snart1"): @[]

  state1 = state(States, Events, Data, Event,
    st1, st2): []

  spec5 = statechart(States, Events, Data, Event,
    st1, "snart1"): [state1]

  spec6 = statechart(States, Events, Data, Event,
    st1, "snart1"): [state(States, Events, Data, Event, st1, st2, [])]



echo ""
echo spec1
echo ""
echo spec2
echo ""
echo spec3
echo ""
echo spec4
echo ""
echo spec4.St
echo spec4.Ev
echo spec4.Dm
echo spec4.Em
echo ""
echo state1
echo ""
echo spec5
echo ""
echo spec6



echo ""



# old stuff
# ------------------------------------------------------------------------------

# const # let
#   spec1 = statechart(States, Events, Data, Event, "snart2", st1): []

#   state1 = state(States, Events, Data, Event, st1, st2): []

#   spec2 = statechart(States, Events, Data, Event, "", st1): [state1]

#   spec3 = statechart(States, Events, Data, Event, "snart2", st1): [
#     state(st1, st2, [])
#   ]

#   spec4 = statechart(States, Events, Data, Event, "snart2", st2): [
#     state(st1, st2, []),
#     state(st2, st1, [])
#   ]

#   spec5 = statechart(States, Events, Data, Event, "snart2", st2): @[
#     state(st1, st2, [
#       state(st2, st1, [
#         state1,
#         state(st2, st1, [])
#     ])]),
#     state(st1, st2, @[
#       state(st2, st1, [state1, state1]),
#       state1
#     ])
#   ]

#   spec6 = statechart(States, Events, Data, Event, "snart2", st2): @[
#     state(st1, st2, [
#       state(st2, st1, [
#         state1,
#         state(st2, st1, []),
#         atomic()
#     ])]),
#     state(st1, st2, [
#       state(st2, st1, [state1, state1]),
#       atomic(st2)
#     ])
#   ]

#   spec7 = statechart(States, Events, Data, Event, "snart2", st2): [
#     parallel(children = [
#       state([])
#     ])
#   ]

#   para1 = parallel(States, Events, Data, Event): []

#   para2 = parallel(States, Events, Data, Event): [state1]

#   para3 = parallel(States, Events, Data, Event, children = [
#     state(st1, st1, [])
#   ])

#   para4 = parallel(States, Events, Data, Event, children = [
#     state(st1, st1, [
#       atomic(),
#       parallel(st2, [
#         state1,
#         state(st1, st2, [
#           parallel(st1, [
#             state1,
#             state1
#           ]),
#           atomic()
#         ])
#       ])
#     ])
#   ])

#   spec8 = statechart(States, Events, Data, Event, "snart2", st2): [
#     parallel(children = [
#       state(st1, st1, [
#         atomic(),
#         parallel(st2, [
#           state1,
#           state(st1, st2, [
#             parallel(st1, [
#               state1,
#               state1
#             ]),
#             atomic()
#           ])
#         ])
#       ])
#     ])
#   ]

#   tran1 = transition(States, Events, Data, Event, evA, st1, tkExternal,
#     cond = (
#       block:
#        debugEcho data
#        debugEcho event
#        debugEcho config
#     ),
#     exe = (
#       block:
#        debugEcho data[]
#        debugEcho event
#        debugEcho config
#     )
#   )

#   spec9 = statechart(States, Events, Data, Event, "snart2", st2): [
#     state(st1, st1, [
#       transition(evA, st2, tkExternal,
#         cond = (
#           block:
#             debugEcho data
#             debugEcho event
#             debugEcho config
#         ),
#         exe = (
#           block:
#             debugEcho data[]
#             debugEcho event
#             debugEcho config
#         )
#       )
#     ]),
#     atomic(st2)
#   ]

# echo ""
# echo spec1
# echo ""
# echo state1
# echo ""
# echo spec2
# echo ""
# echo spec3
# echo ""
# echo spec4
# echo ""
# echo spec5
# echo ""
# echo spec6
# echo ""
# echo spec7
# echo ""
# echo para1
# echo ""
# echo para2
# echo ""
# echo para3
# echo ""
# echo para4
# echo ""
# echo spec8
# echo ""
# echo tran1
# echo ""
# echo (tran1.tCond.get)(Data(id: st1), Event(name: evA), Configuration[States]())
# echo ""
# (tran1.tExe.get)((ref Data)(id: st1), Event(name: evA), Configuration[States]())
# echo ""
# echo spec9
# echo ""
# echo (spec9.children[0].sChildren[0].tCond.get)(
#   Data(id: st1), Event(name: evA), Configuration[States]())
# echo ""
# (spec9.children[0].sChildren[0].tExe.get)(
#   (ref Data)(id: st1), Event(name: evA), Configuration[States]())

# echo ""
