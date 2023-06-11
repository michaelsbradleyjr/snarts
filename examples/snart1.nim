# TODO: simplify
# for now this first example does a bit more than is desirable, primarily as a
# check (along with the tests in ../tests) that the basic facilities are
# working as expected; once the examples have been expanded to cover various
# concepts and usage this example can be simplified

import pkg/snarts

type DataModel = object
  x: string

func init(T: typedesc[DataModel], x: string): T =
  T(x: x)

func init(T: typedesc[DataModel]): T =
  T.init("default")

const
  spec1 = statechart("snart1"): [
    state("s1", [
      state("s2", [
        state([
          state([atomic "s3"])
  ])])])]

  machine1 = spec1.compile.tryGet

echo ""
echo spec1
echo ""
echo machine1
echo ""

const
  spec2 = statechart("snart1"): [
    state("s1", [
      state("s2", [
        state([
          state([atomic "s3"])
  ])])])]

let
  machine2 = spec2.compile.tryGet

echo ""
echo spec2
echo ""
echo machine2
echo ""

let
  spec3 = statechart("snart1"): [
    state("s1", [
      state("s2", [
        state([
          state([atomic "s3"])
  ])])])]

  machine3 = spec3.compile.tryGet

echo ""
echo spec3
echo ""
echo machine3
echo ""

const
  spec4 = DataModel.statechart("snart1"): [
    state("s1", [
      state("s2", [
        state([
          state([atomic "s3"])
  ])])])]

  machine4 = spec4.compile.tryGet

echo ""
echo spec4
echo ""
echo machine4
echo ""

const
  spec5 = DataModel.statechart("snart1"): [
    state("s1", [
      state("s2", [
        state([
          state([atomic "s3"])
  ])])])]

let
  machine5 = spec5.compile.tryGet

echo ""
echo spec5
echo ""
echo machine5
echo ""

let
  spec6 = DataModel.statechart("snart1"): [
    state("s1", [
      state("s2", [
        state([
          state([atomic "s3"])
  ])])])]

  machine6 = spec6.compile.tryGet

echo ""
echo spec6
echo ""
echo machine6
echo ""
