import strutils
import sequtils
import sugar
import sets

stdin.readAll().strip().split("\n\n").mapIt(
  it.split("\n").mapIt(it.toSet()).foldl(a + b).len
).foldl(a + b).echo
