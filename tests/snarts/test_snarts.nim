import pkg/snarts
import pkg/unittest2

# in tests `let` is preferred to `const` because the latter does not generate
# coverate data

func `==`[St, Ev, Dm, Em](a, b: StatechartNode[St, Ev, Dm, Em]): bool =
  if a.kind != b.kind:
    result = false
  else:
    case a.kind
    of snkState:
      result = (
        (a.sId == b.sId) and
        (a.sInitial == b.sInitial) and
        (a.sChildren == b.sChildren))
    else:
      result = false

func `==`[St, Ev, Dm, Em](a, b: Statechart[St, Ev, Dm, Em]): bool =
  (a.scInitial == b.scInitial) and
  (a.scName == b.scName) and
  (a.scChildren == b.scChildren)

suite "DSL":
  test "combinations of usage should not cause compile-time errors":
    type
      States = enum
        st1, st2

      Events = enum
        evA

      Data = object
        id: States

      Event = object
        name: Events



    # newer old stuff
    # --------------------------------------------------------------------------

    # let chart0 =
    #   statechart[States, Events, Data, Event]()

    # let chart1 =
    #   statechart[States, Events, Data, Event]([])

    # let state0 =
    #   state[States, Events, Data, Event]()

    # let state1 =
    #   state[States, Events, Data, Event]([])

    # debugEcho ""
    # debugEcho $chart0.St
    # debugEcho $chart0.Ev
    # debugEcho $chart0.Dm
    # debugEcho $chart0.Em

    # debugEcho ""
    # debugEcho chart0
    # debugEcho ""
    # debugEcho chart1

    # debugEcho ""
    # debugEcho state0
    # debugEcho ""
    # debugEcho state1

    # let chart2 =
    #   statechart[States, Events, Data, Event](
    #     fixup(States, Events, Data, Event, [
    #       state([
    #         state[States, Events, Data, Event]()
    #       ]),
    #       state([
    #         state[States, Events, Data, Event]()
    #       ]),
    #       state()
    #     ])
    #   )

    # let chart3 =
    #   statechart3(States, Events, Data, Event, "grimmy", st2, @[
    #     state[States, Events, Data, Event]([
    #       state[States, Events, Data, Event]()
    #     ]),
    #     state([
    #       state[States, Events, Data, Event]()
    #     ]),
    #     state([
    #       state[States, Events, Data, Event]()
    #     ]),
    #     state([
    #       state[States, Events, Data, Event]()
    #     ]),
    #     state[States, Events, Data, Event](st1, st2),
    #     state(),
    #     state(st1, st2)
    #   ])

    # was/am having a problem with non-bracketed varargs
    # --------------------------------------------------
    # let chart4 =
    #   statechart[States, Events, Data, Event](
    #     fixup(States, Events, Data, Event,
    #       state[States, Events, Data, Event](),
    #       state[States, Events, Data, Event](),
    #       state(),
    #       state(st1, st2)
    #     )
    #   )

    # debugEcho ""
    # debugEcho chart2
    # debugEcho ""
    # debugEcho chart3
    # debugEcho ""
    # debugEcho chart4

    # debugEcho ""



    # old stuff
    # --------------------------------------------------------------------------

    # # ?? why does the following cause a compile-time error
    # # i.e. when same/similar code below it does not
    # # var chartTest = Statechart[States, Events, Data, Event]()

    # # this works instead...
    # var chartTest =
    #   statechart(States, Events, Data, Event)

    # let chart0 =
    #   Statechart[States, Events, Data, Event]()

    # check:
    #   statechart(States, Events, Data, Event) ==
    #     chart0

    # let chart1 =
    #   Statechart[States, Events, Data, Event](
    #     scChildren: @[])

    # check:
    #   statechart(States, Events, Data, Event, []) ==
    #     chart1
    #   statechart(States, Events, Data, Event, children = []) ==
    #     chart1
    # chartTest = statechart(States, Events, Data, Event): []
    # check:
    #   chartTest ==
    #     chart1
    # check:
    #   statechart(States, Events, Data, Event, @[]) ==
    #     chart1
    #   statechart(States, Events, Data, Event, children = @[]) ==
    #     chart1
    # chartTest = statechart(States, Events, Data, Event): @[]
    # check:
    #   chartTest ==
    #     chart1

    # let chart2a =
    #   Statechart[States, Events, Data, Event](
    #     scName: Opt.some "test",
    #     scChildren: @[])

    # check:
    #   statechart(States, Events, Data, Event, "test", []) ==
    #     chart2a
    #   statechart(States, Events, Data, Event, "test", children = []) ==
    #     chart2a
    # chartTest = statechart(States, Events, Data, Event, "test"): []
    # check:
    #   chartTest ==
    #     chart2a
    # check:
    #   statechart(States, Events, Data, Event, name = "test", []) ==
    #     chart2a
    # chartTest = statechart(States, Events, Data, Event, name = "test"): []
    # check:
    #   chartTest ==
    #     chart2a
    # check:
    #   statechart(States, Events, Data, Event, name = "test", children = []) ==
    #     chart2a
    #   statechart(States, Events, Data, Event, children = [], name = "test") ==
    #     chart2a
    # check:
    #   statechart(States, Events, Data, Event, "test", @[]) ==
    #     chart2a
    #   statechart(States, Events, Data, Event, "test", children = @[]) ==
    #     chart2a
    # chartTest = statechart(States, Events, Data, Event, "test"): @[]
    # check:
    #   chartTest ==
    #     chart2a
    # check:
    #   statechart(States, Events, Data, Event, name = "test", @[]) ==
    #     chart2a
    # chartTest = statechart(States, Events, Data, Event, name = "test"): @[]
    # check:
    #   chartTest ==
    #     chart2a
    # check:
    #   statechart(States, Events, Data, Event, name = "test", children = @[]) ==
    #     chart2a
    #   statechart(States, Events, Data, Event, children = @[], name = "test") ==
    #     chart2a

    # let chart2b =
    #   Statechart[States, Events, Data, Event](
    #     scInitial: Opt.some st1,
    #     scChildren: @[])

    # check:
    #   statechart(States, Events, Data, Event, st1, []) ==
    #     chart2b
    #   statechart(States, Events, Data, Event, st1, children = []) ==
    #     chart2b
    # chartTest = statechart(States, Events, Data, Event, st1): []
    # check:
    #   chartTest ==
    #     chart2b
    # check:
    #   statechart(States, Events, Data, Event, initial = st1, []) ==
    #     chart2b
    # chartTest = statechart(States, Events, Data, Event, initial = st1): []
    # check:
    #   chartTest ==
    #     chart2b
    # check:
    #   statechart(States, Events, Data, Event, initial = st1, children = []) ==
    #     chart2b
    #   statechart(States, Events, Data, Event, children = [], initial = st1) ==
    #     chart2b
    # check:
    #   statechart(States, Events, Data, Event, st1, @[]) ==
    #     chart2b
    #   statechart(States, Events, Data, Event, st1, children = @[]) ==
    #     chart2b
    # chartTest = statechart(States, Events, Data, Event, st1): @[]
    # check:
    #   chartTest ==
    #     chart2b
    # check:
    #   statechart(States, Events, Data, Event, initial = st1, @[]) ==
    #     chart2b
    # chartTest = statechart(States, Events, Data, Event, initial = st1): @[]
    # check:
    #   chartTest ==
    #     chart2b
    # check:
    #   statechart(States, Events, Data, Event, initial = st1, children = @[]) ==
    #     chart2b
    #   statechart(States, Events, Data, Event, children = @[], initial = st1) ==
    #     chart2b

    # let chart3 =
    #   Statechart[States, Events, Data, Event](
    #     scInitial: Opt.some st1,
    #     scName: Opt.some "test",
    #     scChildren: @[])

    # check:
    #   statechart(States, Events, Data, Event, "test", st1, []) ==
    #     chart3
    #   statechart(States, Events, Data, Event, "test", st1, children = []) ==
    #     chart3
    # chartTest = statechart(States, Events, Data, Event, "test", st1): []
    # check:
    #   chartTest ==
    #     chart3
    # check:
    #   statechart(States, Events, Data, Event, name = "test", st1, []) ==
    #     chart3
    #   statechart(States, Events, Data, Event, name = "test", st1, children = []) ==
    #     chart3
    # chartTest = statechart(States, Events, Data, Event, name = "test", st1): []
    # check:
    #   chartTest ==
    #     chart3
    # check:
    #   statechart(States, Events, Data, Event, "test", initial = st1, []) ==
    #     chart3
    # chartTest = statechart(States, Events, Data, Event, "test", initial = st1): []
    # check:
    #   chartTest ==
    #     chart3
    # check:
    #   statechart(States, Events, Data, Event, "test", initial = st1, children = []) ==
    #     chart3
    #   statechart(States, Events, Data, Event, "test", children = [], initial = st1) ==
    #     chart3
    # check:
    #   statechart(States, Events, Data, Event, name = "test", initial = st1, []) ==
    #     chart3
    # chartTest = statechart(States, Events, Data, Event, name = "test", initial = st1): []
    # check:
    #   chartTest ==
    #     chart3
    # check:
    #   statechart(States, Events, Data, Event, name = "test", initial = st1, children = []) ==
    #     chart3
    #   statechart(States, Events, Data, Event, name = "test", children = [], initial = st1) ==
    #     chart3
    #   statechart(States, Events, Data, Event, initial = st1, name = "test", children = []) ==
    #     chart3
    #   statechart(States, Events, Data, Event, initial = st1, children = [], name = "test") ==
    #     chart3
    #   statechart(States, Events, Data, Event, children = [], name = "test", initial = st1) ==
    #     chart3
    #   statechart(States, Events, Data, Event, children = [], initial = st1, name = "test") ==
    #     chart3
    # check:
    #   statechart(States, Events, Data, Event, "test", st1, @[]) ==
    #     chart3
    #   statechart(States, Events, Data, Event, "test", st1, children = @[]) ==
    #     chart3
    # chartTest = statechart(States, Events, Data, Event, "test", st1): @[]
    # check:
    #   chartTest ==
    #     chart3
    # check:
    #   statechart(States, Events, Data, Event, name = "test", st1, @[]) ==
    #     chart3
    #   statechart(States, Events, Data, Event, name = "test", st1, children = @[]) ==
    #     chart3
    # chartTest = statechart(States, Events, Data, Event, name = "test", st1): @[]
    # check:
    #   chartTest ==
    #     chart3
    # check:
    #   statechart(States, Events, Data, Event, "test", initial = st1, @[]) ==
    #     chart3
    # chartTest = statechart(States, Events, Data, Event, "test", initial = st1): @[]
    # check:
    #   chartTest ==
    #     chart3
    # check:
    #   statechart(States, Events, Data, Event, "test", initial = st1, children = @[]) ==
    #     chart3
    #   statechart(States, Events, Data, Event, "test", children = @[], initial = st1) ==
    #     chart3
    # check:
    #   statechart(States, Events, Data, Event, name = "test", initial = st1, @[]) ==
    #     chart3
    # chartTest = statechart(States, Events, Data, Event, name = "test", initial = st1): @[]
    # check:
    #   chartTest ==
    #     chart3
    # check:
    #   statechart(States, Events, Data, Event, name = "test", initial = st1, children = @[]) ==
    #     chart3
    #   statechart(States, Events, Data, Event, name = "test", children = @[], initial = st1) ==
    #     chart3
    #   statechart(States, Events, Data, Event, initial = st1, name = "test", children = @[]) ==
    #     chart3
    #   statechart(States, Events, Data, Event, initial = st1, children = @[], name = "test") ==
    #     chart3
    #   statechart(States, Events, Data, Event, children = @[], name = "test", initial = st1) ==
    #     chart3
    #   statechart(States, Events, Data, Event, children = @[], initial = st1, name = "test") ==
    #     chart3

    # var stateTest =
    #   StatechartNode[States, Events, Data, Event](
    #     kind: snkState)

    # let state0 =
    #   StatechartNode[States, Events, Data, Event](
    #     kind: snkState)

    # check:
    #   state(States, Events, Data, Event) ==
    #     state0
    #   anon(States, Events, Data, Event) ==
    #     state0

    # let state1a =
    #   StatechartNode[States, Events, Data, Event](
    #     kind: snkState,
    #     sId: Opt.some st1)

    # check:
    #   state(States, Events, Data, Event, st1) ==
    #     state1a
    #   state(States, Events, Data, Event, id = st1) ==
    #     state1a

    # let state1b =
    #   StatechartNode[States, Events, Data, Event](
    #     kind: snkState,
    #     sInitial: Opt.some st1)

    # check:
    #   anon(States, Events, Data, Event, st1) ==
    #     state1b
    #   anon(States, Events, Data, Event, initial = st1) ==
    #     state1b

    # let state1c =
    #   StatechartNode[States, Events, Data, Event](
    #     kind: snkState,
    #     sChildren: @[])

    # check:
    #   state(States, Events, Data, Event, []) ==
    #     state1c
    #   state(States, Events, Data, Event, children = []) ==
    #     state1c
    # stateTest = state(States, Events, Data, Event): []
    # check:
    #   stateTest ==
    #     state1c
    # check:
    #   anon(States, Events, Data, Event, []) ==
    #     state1c
    #   anon(States, Events, Data, Event, children = []) ==
    #     state1c
    # stateTest = anon(States, Events, Data, Event): []
    # check:
    #   stateTest ==
    #     state1c
    # check:
    #   state(States, Events, Data, Event, @[]) ==
    #     state1c
    #   state(States, Events, Data, Event, children = @[]) ==
    #     state1c
    # stateTest = state(States, Events, Data, Event): @[]
    # check:
    #   stateTest ==
    #     state1c
    # check:
    #   anon(States, Events, Data, Event, @[]) ==
    #     state1c
    #   anon(States, Events, Data, Event, children = @[]) ==
    #     state1c
    # stateTest = anon(States, Events, Data, Event): @[]
    # check:
    #   stateTest ==
    #     state1c

    # # let
    # #   state2a = state(States, Events, Data, Event, st1, st2)
    # #   state2b = state(States, Events, Data, Event, id = st1, st2)
    # #   state2c = state(States, Events, Data, Event, id = st1, initial = st2)
    # #   state2d = state(States, Events, Data, Event, initial = st2, id = st1)
    # #   state2e = state(States, Events, Data, Event, st1, initial = st2)
    # #   state2f = state(States, Events, Data, Event, st1, [])
    # #   state2g = state(States, Events, Data, Event, st1): []
    # #   state2h = state(States, Events, Data, Event, id = st1, [])
    # #   state2i = state(States, Events, Data, Event, id = st1): []
    # #   state2j = state(States, Events, Data, Event, id = st1, children = [])
    # #   state2k = state(States, Events, Data, Event, children = [], id = st1)
    # #   state2l = state(States, Events, Data, Event, st1, children = [])
    # #   state2m = anon(States, Events, Data, Event, st1, [])
    # #   state2n = anon(States, Events, Data, Event, st1): []
    # #   state2o = anon(States, Events, Data, Event, initial = st2, [])
    # #   state2p = anon(States, Events, Data, Event, initial = st2): []
    # #   state2q = anon(States, Events, Data, Event, initial = st2, children = [])
    # #   state2r = anon(States, Events, Data, Event, children = [], initial = st2)
    # #   state2s = anon(States, Events, Data, Event, st2, children = [])

    # #   state3a = state(States, Events, Data, Event, st1, st2, [])
    # #   state3b = state(States, Events, Data, Event, st1, st2): []
    # #   state3c = state(States, Events, Data, Event, id = st1, st2, [])
    # #   state3d = state(States, Events, Data, Event, id = st1, st2): []
    # #   state3e = state(States, Events, Data, Event, id = st1, initial = st2, [])
    # #   state3f = state(States, Events, Data, Event, id = st1, initial = st2): []
    # #   state3g = state(States, Events, Data, Event, id = st1, initial = st2, children = [])
    # #   state3h = state(States, Events, Data, Event, id = st1, children = [], initial = st2)
    # #   state3i = state(States, Events, Data, Event, initial = st2, id = st1, children = [])
    # #   state3j = state(States, Events, Data, Event, initial = st2, children = [], id = st1)
    # #   state3k = state(States, Events, Data, Event, children = [], id = st1, initial = st2)
    # #   state3l = state(States, Events, Data, Event, children = [], initial = st2, id = st1)
    # #   state3m = state(States, Events, Data, Event, st1, initial = st2, [])
    # #   state3n = state(States, Events, Data, Event, st1, initial = st2): []
    # #   state3o = state(States, Events, Data, Event, st1, initial = st2, children = [])
    # #   state3p = state(States, Events, Data, Event, st1, children = [], initial = st2)
    # #   state3q = state(States, Events, Data, Event, st1, st2, children = [])

    # # --------------------------------------------------------------------------

    # # do the following after all the variations for state, parallel, etc. are
    # # worked out (though should probably be replaced with fully macro-ized
    # # randomized iterations for all variations)

    # # for now can work out issues when fixup is in play for state in statechart

    # # ?? maybe might work if defined outside the suite/test
    # # !! realized the problem: when using only a mix of the `= 0` templates all
    # #    members of the collection have the same type, but when mixing in
    # #    another proc/template call where the return type is
    # #    StatechartNode[...] then the compiler raises an exception... is there
    # #    some way to defer analysis of the collection ??
    # # proc state0P(x: int): StatechartNode[States, Events, Data, Event] =
    # #   state(States, Events, Data, Event)

    # # template state0T(x: untyped): untyped =
    # #   state(States, Events, Data, Event)

    # # let
    # #   state0V = state(States, Events, Data, Event)

    # # maybe try varargs[untyped] though I'm thinking it may not make a
    # # difference with the untyped-overload problem I seem to be having

    # let
    #   spec1 = statechart(States, Events, Data, Event, [
    #     # `snarts.anon|state()` doesn't work, need to understand better 0 and
    #     # 1+ arg forms of DotExpr:
    #     # -------------------------------------------------------------------
    #     # Bracket
    #     #   Call
    #     #     DotExpr
    #     #       Ident "snarts"
    #     #       Ident "state"
    #     # anon(),
    #     # state(),

    #     # this doesn't work either, see !! comment above
    #     # state(States, Events, Data, Event)

    #     # want to explore this in relation to outerscope having `state` (or
    #     # `anon`, etc.) that's a proc and in collision with `snarts.state`, but
    #     # see comments above re: DotExpr
    #     # state0T(123),

    #     # want to explore this in relation to outerscope having `state` (or
    #     # `anon`, etc.) that's a value and in collision with `snarts.state`,
    #     # but see comments above re: DotExpr
    #     # state0V
    #   ])

    # check:
    #   spec1 == Statechart[States, Events, Data, Event](
    #     scChildren: @[
    #       # StatechartNode[States, Events, Data, Event](
    #       #   kind: snkState,
    #       #   sChildren: @[]),
    #       # StatechartNode[States, Events, Data, Event](
    #       #   kind: snkState,
    #       #   sChildren: @[]),
    #       # StatechartNode[States, Events, Data, Event](
    #       #   kind: snkState,
    #       #   sChildren: @[]),
    #       # StatechartNode[States, Events, Data, Event](
    #       #   kind: snkState,
    #       #   sChildren: @[])
    #   ])

    # let
    #   spec2 = statechart(States, Events, Data, Event, [
    #     # state(st1),
    #     # anon(st2),
    #     # anon([]),
    #     # state([]),
    #     # anon(@[]),
    #     # state(@[]),
    #     # state0T(123),
    #     # state0V
    #   ])

    # check:
    #   spec2 == Statechart[States, Events, Data, Event](
    #     scChildren: @[
    #       # StatechartNode[States, Events, Data, Event](
    #       #   kind: snkState,
    #       #   sId: Opt.some st1,
    #       #   sChildren: @[]),
    #       # StatechartNode[States, Events, Data, Event](
    #       #   kind: snkState,
    #       #   sId: Opt.some st1,
    #       #   sChildren: @[]),
    #       # StatechartNode[States, Events, Data, Event](
    #       #   kind: snkState,
    #       #   sId: Opt.some st1,
    #       #   sChildren: @[]),
    #       # StatechartNode[States, Events, Data, Event](
    #       #   kind: snkState,
    #       #   sInitial: Opt.some st2,
    #       #   sChildren: @[]),
    #       # StatechartNode[States, Events, Data, Event](
    #       #   kind: snkState,
    #       #   sChildren: @[]),
    #       # StatechartNode[States, Events, Data, Event](
    #       #   kind: snkState,
    #       #   sChildren: @[]),
    #       # StatechartNode[States, Events, Data, Event](
    #       #   kind: snkState,
    #       #   sChildren: @[]),
    #       # StatechartNode[States, Events, Data, Event](
    #       #   kind: snkState,
    #       #   sChildren: @[])
    #     ])

    # # --------------------------------------------------------------------------

    # # re-enable this check after working out all the above; leave it disabled
    # # for now because with `-d:debugMacros` the output resulting from the code
    # # below makes it more difficult to sort out what errored and why (i.e. as
    # # the DSL front-end is sorted out)

    # # check:
    # #   statechart(States, Events, Data, Event, "", []) ==
    # #     Statechart[States, Events, Data, Event]()
    # #   statechart(States, Events, Data, Event, "", []) ==
    # #     Statechart[States, Events, Data, Event](scName: Opt.none string)
    # #   statechart(States, Events, Data, Event, "test", []) ==
    # #     Statechart[States, Events, Data, Event](scName: Opt.some "test")

suite "Validation":
  test "statechart must have one or more children":
    check: true
