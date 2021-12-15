import sequtils
import strutils
import parseutils
import bitops
import sets
import tables
import options

var input = stdin.readLine
discard stdin.readLine

let replacements = stdin.readAll.strip.split("\n").mapIt(it.split(" -> ")).mapIt(((it[0][0], it[0][1]), it[1])).toTable

var cache = initTable[tuple[input: tuple[a: char, b: char], steps: int], CountTable[char]]()

proc within(input: tuple[a: char, b: char], steps: int): CountTable[char] =
  if cache.hasKey((input, steps)):
    result = cache[(input, steps)]
  elif steps == 0:
    result = initCountTable[char]()
  elif replacements.hasKey(input):
    let left = within((input.a, replacements[input][0]), steps - 1)
    let right = within((replacements[input][0], input.b), steps - 1)
    result.inc(replacements[input][0])
    result.merge(left)
    result.merge(right)
  else:
    result = initCountTable[char]()

  cache[(input, steps)] = result

var counts = toCountTable(input)
for i in input.low .. (input.high - 1):
  counts.merge(within((input[i], input[i + 1]), 40))

echo counts.largest.val - counts.smallest.val
