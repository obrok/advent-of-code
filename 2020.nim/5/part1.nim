import strutils
import sequtils

stdin.readAll().strip().split().
  mapIt(it.replace('F', '0').replace('B', '1').replace('L', '0').replace('R', '1')).
  mapIt(fromBin[int](it)).
  max.
  echo
