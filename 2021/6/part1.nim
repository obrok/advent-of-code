import sequtils
import strutils
import parseutils
import bitops
import sets
import tables

var ages = [0, 0, 0, 0, 0, 0, 0, 0, 0]

for age in stdin.readLine.split(",").map(parseInt):
  ages[age] += 1

for day in 1..256:
  var newAges = [0, 0, 0, 0, 0, 0, 0, 0, 0]
  for x in 1..8:
    newAges[x - 1] = ages[x]
  newAges[6] += ages[0]
  newAges[8] += ages[0]
  ages = newAges

echo ages.foldl(a + b)
