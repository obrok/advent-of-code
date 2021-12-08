import sequtils
import strutils
import parseutils
import bitops
import sets
import tables

let positions = stdin.readLine.split(",").map(parseInt)

var best = positions.foldl(a + b)
for option in positions[positions.minIndex] .. positions[positions.maxIndex]:
  let value = positions.mapIt(abs(it - option)).foldl(a + b)
  best = min(best, value)

echo best
