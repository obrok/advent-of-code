import sequtils
import strutils
import parseutils
import bitops
import sets
import tables
import options
import deques
import std/heapQueue
import std/strformat
import algorithm
import sugar

proc step(map: seq[seq[char]]): seq[seq[char]] =
  var map = map
  result = map
  for x in 0..map.high:
    for y in 0..map[x].high:
      if map[x][y] == '>' and map[x][(y + 1) mod map[x].len] == '.':
        result[x][y] = '.'
        result[x][(y + 1) mod map[x].len] = '>'
  map = result
  for x in 0..map.high:
    for y in 0..map[x].high:
      if map[x][y] == 'v' and map[(x + 1) mod map.len][y] == '.':
        result[x][y] = '.'
        result[(x + 1) mod map.len][y] = 'v'

var map = stdin.readAll.strip.split("\n").mapIt(it.toSeq).toSeq
var i = 1

while true:
  let new_map = map.step
  if new_map == map:
    break
  map = new_map
  i += 1

echo i
