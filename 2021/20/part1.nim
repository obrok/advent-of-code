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

type Image = tuple[im: Table[(int, int), char], bg: char]

proc pixel(image: Image, x: int, y: int, lookup: string): char =
  var idx = 0
  for b in y - 1 .. y + 1:
    for a in x - 1 .. x + 1:
      idx *= 2
      if image.im.getOrDefault((a, b), image.bg) == '#':
        idx += 1
  return lookup[idx]

proc bounds(image: Image): (int, int, int, int) =
  let xs = collect:
    for k in image.im.keys: k[0]
  let ys = collect:
    for k in image.im.keys: k[1]
  let min_x = xs[xs.minIndex]
  let max_x = xs[xs.maxIndex]
  let min_y = ys[ys.minIndex]
  let max_y = ys[ys.maxIndex]
  return (min_x, max_x, min_y, max_y)

proc step(image: Image, lookup: string): Image =
  let (min_x, max_x, min_y, max_y) = bounds(image)
  let im = collect:
    for x in min_x - 1 .. max_x + 1:
      for y in min_y - 1 .. max_y + 1:
        {(x, y): pixel(image, x, y, lookup)}
  let bg =
    if image.bg == '.': lookup[0] else: lookup[256]

  return (im: im, bg: bg)

proc print(image: Image) =
  let (min_x, max_x, min_y, max_y) = bounds(image)
  for y in min_y - 2 .. max_y + 2:
    for x in min_x - 2 .. max_x + 2:
      stdout.write(image.im.getOrDefault((x, y), image.bg))
    stdout.write("\n")
  stdout.write("\n")

let lookup = stdin.readline
discard stdin.readline

let im = collect:
  for i, line in stdin.readAll.strip.split("\n").pairs():
    for j, c in line:
      {(j, i): c}
var image = (im: im, bg: '.')

image = image.step(lookup).step(lookup)

let light = collect:
  for k, v in image.im:
    if v == '#':
      v
echo light.len

