import sequtils
import strutils
import parseutils
import bitops
import sets
import tables
import options

var input = stdin.readLine
discard stdin.readLine

let replacements = stdin.readAll.strip.split("\n").mapIt(it.split(" -> ")).mapIt((it[0], it[1])).toTable

for step in 1 .. 10:
  var next = ""
  for i in input.low .. (input.high - 1):
    next.add(input[i..i])
    let key = input[i..(i+1)]
    if replacements.hasKey(key):
      next.add(replacements[key])
  next.add(input[input.high])
  input = next

var counts = newCountTable(input)
echo counts.largest.val - counts.smallest.val
