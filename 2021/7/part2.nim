import sequtils
import strutils
import parseutils
import bitops
import sets
import tables

let positions = stdin.readLine.split(",").map(parseInt)

var best = high(int)
for option in positions[positions.minIndex] .. positions[positions.maxIndex]:
  let value = positions.
    mapIt((abs(it - option) + 1) * abs(it - option) div 2).
    foldl(a + b)

  best = min(best, value)

echo best
