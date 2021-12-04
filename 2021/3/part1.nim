import sequtils
import strutils
import parseutils
import bitops

let data = stdin.readAll().strip().splitLines()
var numbers: seq[uint] = @[]

for binary in data:
  var number: uint
  doAssert parseBin(binary, number) == binary.len
  numbers.add(number)

var gamma: uint = 0
var epsilon: uint = 0

for bit in data[0].low .. data[0].high:
  let mask: uint = 1u.rotateLeftBits(bit)
  let ones = numbers.filter(proc(x: uint): bool = mask.bitand(x) > 0).len

  if ones > data.len.div(2):
    gamma = gamma.bitor(mask)
  else:
    epsilon = epsilon.bitor(mask)

echo gamma * epsilon
