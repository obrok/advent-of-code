import algorithm
import strutils
import sequtils

let ids = stdin.readAll().strip().split().
  mapIt(it.replace('F', '0').replace('B', '1').replace('L', '0').replace('R', '1')).
  mapIt(fromBin[int](it)).
  sorted()

let gap = (0 ..< (ids.len - 1)).toSeq().filterIt(ids[it] + 1 != ids[it + 1])[0]
echo ids[gap] + 1
