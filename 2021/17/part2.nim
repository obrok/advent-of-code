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

let coords = stdin.readLine.split(": ")[1].split(", ")
let x_bounds = coords[0].split("=")[1].split("..").mapIt(parseInt(it))
let y_bounds = coords[1].split("=")[1].split("..").mapIt(parseInt(it))

let min_x_velocity = 0
let max_x_velocity = x_bounds[1]
let min_y_velocity = y_bounds[0]
var max_y_velocity = 1

while true:
  max_y_velocity *= 2
  var y = 0
  var last_y = 0
  var y_velocity = max_y_velocity
  while y >= y_bounds[0]:
    last_y = y
    y += y_velocity
    y_velocity -= 1
  if last_y >= 0 and y < y_bounds[0]:
    break

var count = 0
for y_velocity in min_y_velocity..max_y_velocity:
  for x_velocity in min_x_velocity..max_x_velocity:
    var x = 0
    var y = 0
    var x_velocity = x_velocity
    var y_velocity = y_velocity
    var max_y = 0
    while x <= x_bounds[1] and y >= y_bounds[0]:
      x += x_velocity
      y += y_velocity
      x_velocity = max(x_velocity - 1, 0)
      y_velocity -= 1
      max_y = max(y, max_y)
      if x >= x_bounds[0] and x <= x_bounds[1] and y >= y_bounds[0] and y <= y_bounds[1]:
        count += 1
        break

echo count
