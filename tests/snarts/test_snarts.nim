import pkg/snarts
import pkg/unittest2

suite "Templates":
  test "combinations of usage should not cause compile-time errors":
    type
      States = enum
        st1, st2

      Events = enum
        evA, evB

      Data = object
        id: States

      Event = object
        name: Events

    const
      state1 = state(States, Events, Data, Event, st1, st2): []

      spec1 = statechart(States, Events, Data, Event, "snart1", st1, [])

      spec2 = statechart(States, Events, Data, Event, "snart1", st1, @[])

    let
      spec3 = statechart(States, Events, Data, Event, "snart1", st1): []

      spec4 = statechart(States, Events, Data, Event, "snart1", st1): @[]

      spec5 = statechart(States, Events, Data, Event, "snart1", st1): [
        state1
      ]

    const
      spec6 = statechart(States, Events, Data, Event, "snart1", st1): [
        state1,
        state(States, Events, Data, Event, st1, st2, []),
        state1
      ]

    let
      spec7 = statechart(States, Events, Data, Event, "snart1", st1): [
        state1,
        state(st1, st2, []),
        state1
      ]

    echo ""
    echo state1
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

    check:
      spec1.St is States
      spec1.Ev is Events
      spec1.Dm is Data
      spec1.Em is Event

    const
      tran1 = initTransition[States, Events, Data, Event]()

    echo ""
    echo tran1

    echo ""

suite "Validation":
  test "statechart must have one or more children":
    check: true

    # old stuff
    # --------------------------------------------------------------------------
    # const
    #   spec1 = statechart: []
    #   spec2 = DataModel_1.statechart: []
    # let
    #   spec3 = statechart: []
    #   spec4 = DataModel_1.statechart: []

    # check:
    #   spec1 of Statechart[Void]
    #   spec2 of Statechart[DataModel_1]
    #   spec3 of Statechart[Void]
    #   spec4 of Statechart[DataModel_1]

    # let
    #   res1 = spec1.compile
    #   res2 = spec2.compile
    #   res3 = spec3.compile
    #   res4 = spec4.compile

    # check:
    #   res1.isErr
    #   res1.unsafeError.errors.len == 1
    #   "has no states" in res1.unsafeError.errors[0].msg
    #   res2.isErr
    #   res2.unsafeError.errors.len == 1
    #   "has no states" in res2.unsafeError.errors[0].msg
    #   res3.isErr
    #   res3.unsafeError.errors.len == 1
    #   "has no states" in res3.unsafeError.errors[0].msg
    #   res4.isErr
    #   res4.unsafeError.errors.len == 1
    #   "has no states" in res4.unsafeError.errors[0].msg

    # const
    #   children1 = [atomic()]
    #   spec5 = statechart: children1
    #   spec6 = DataModel_1.statechart: children1
    # let
    #   children2 = @[atomic()]
    #   spec7 = statechart: children1
    #   spec8 = DataModel_1.statechart: children2

    # check:
    #   spec5 of Statechart[Void]
    #   spec6 of Statechart[DataModel_1]
    #   spec7 of Statechart[Void]
    #   spec8 of Statechart[DataModel_1]

    # let
    #   res5 = spec5.compile
    #   res6 = spec6.compile
    #   res7 = spec7.compile
    #   res8 = spec8.compile

    # check:
    #   res5.isOk and res5.get of Machine[Void]
    #   res6.isOk and res6.get of Machine[DataModel_1]
    #   res7.isOk and res7.get of Machine[Void]
    #   res8.isOk and res8.get of Machine[DataModel_1]

    # const
    #   mach5 = spec5.compile.tryGet
    #   mach6 = spec6.compile.tryGet
    # let
    #   mach7 = spec7.compile.tryGet
    #   mach8 = spec8.compile.tryGet

    # check:
    #   mach5 of Machine[Void]
    #   mach6 of Machine[DataModel_1]
    #   mach7 of Machine[Void]
    #   mach8 of Machine[DataModel_1]

    # enable to see how ValidationDefect is reported in compile-time output
    # const
    #   spec9  = statechart: []
    #   mach9  = spec9.compile.tryGet
    #   spec10 = DataModel_1.statechart: []
    #   mach10 = spec10.compile.tryGet
