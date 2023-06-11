import std/strutils
import pkg/snarts
import pkg/unittest2

type DataModel_1 = object
  x: string

func init(T: typedesc[DataModel_1], x: string): T =
  T(x: x)

func init(T: typedesc[DataModel_1]): T =
  T.init("test")

suite "Validation":
  test "statechart must have one or more children":
    # enable to see how ValidationDefect looks in compile-time output
    # ---------------------------------------------------------------
    # const
    #   spec0a = statechart: []
    #   mac0a = spec0a.compile.tryGet
    #   spec0b = DataModel_1.statechart("test"): []
    #   mac0b = spec0b.compile.tryGet

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
      spec5 = statechart: [
        state("s1", [
          state("s2", [
            state([atomic "s3"])
      ])])]

      spec6 = DataModel_1.statechart: [
        state("s1", [
          state("s2", [
            state([atomic "s3"])
      ])])]

    let
      spec7 = statechart: [
        state("s1", [
          state("s2", [
            state([atomic "s3"])
      ])])]

      spec8 = DataModel_1.statechart: [
        state("s1", [
          state("s2", [
            state([atomic "s3"])
      ])])]

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
      mac5 = spec5.compile.tryGet
      mac6 = spec6.compile.tryGet
    let
      mac7 = spec7.compile.tryGet
      mac8 = spec8.compile.tryGet

    check:
      mac5 of Machine[Void]
      mac6 of Machine[DataModel_1]
      mac7 of Machine[Void]
      mac8 of Machine[DataModel_1]
