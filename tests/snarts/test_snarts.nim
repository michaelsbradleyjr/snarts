import std/strutils
import pkg/snarts
import pkg/unittest2

{.hint[CondTrue]: off.}

type DataModel_1 = object
  x: string

func init(T: typedesc[DataModel_1], x: string): T =
  T(x: x)

func init(T: typedesc[DataModel_1]): T =
  T.init("test")

suite "Validation":
  test "statechart must have one or more children":
    const
      spec1 = statechart: []
      spec2 = DataModel_1.statechart: []
    let
      spec3 = statechart: []
      spec4 = DataModel_1.statechart: []

    check:
      spec1 of Statechart[Void]
      spec2 of Statechart[DataModel_1]
      spec3 of Statechart[Void]
      spec4 of Statechart[DataModel_1]

    let
      res1 = spec1.compile
      res2 = spec2.compile
      res3 = spec3.compile
      res4 = spec4.compile

    check:
      res1.isErr
      res1.unsafeError.errors.len == 1
      "has no states" in res1.unsafeError.errors[0].msg
      res2.isErr
      res2.unsafeError.errors.len == 1
      "has no states" in res2.unsafeError.errors[0].msg
      res3.isErr
      res3.unsafeError.errors.len == 1
      "has no states" in res3.unsafeError.errors[0].msg
      res4.isErr
      res4.unsafeError.errors.len == 1
      "has no states" in res4.unsafeError.errors[0].msg

    const
      children1 = [atomic]
      spec5 = statechart: children1
      spec6 = DataModel_1.statechart: children1

    let
      children2 = @[atomic]
      spec7 = statechart: children1
      spec8 = DataModel_1.statechart: children2

    check:
      spec5 of Statechart[Void]
      spec6 of Statechart[DataModel_1]
      spec7 of Statechart[Void]
      spec8 of Statechart[DataModel_1]

    let
      res5 = spec5.compile
      res6 = spec6.compile
      res7 = spec7.compile
      res8 = spec8.compile

    check:
      res5.isOk and res5.get of Machine[Void]
      res6.isOk and res6.get of Machine[DataModel_1]
      res7.isOk and res7.get of Machine[Void]
      res8.isOk and res8.get of Machine[DataModel_1]

    const
      mach5 = spec5.compile.tryGet
      mach6 = spec6.compile.tryGet
    let
      mach7 = spec7.compile.tryGet
      mach8 = spec8.compile.tryGet

    check:
      mach5 of Machine[Void]
      mach6 of Machine[DataModel_1]
      mach7 of Machine[Void]
      mach8 of Machine[DataModel_1]

    # enable to see how ValidationDefect is reported in compile-time output
    # const
    #   spec9  = statechart: []
    #   mach9  = spec9.compile.tryGet
    #   spec10 = DataModel_1.statechart: []
    #   mach10 = spec10.compile.tryGet
