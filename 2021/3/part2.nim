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

var co2s = numbers
var oxygens = numbers

for bit in countdown(data[0].high, data[0].low):
  if co2s.len == 1:
    break

  let mask: uint = 1u.rotateLeftBits(bit)

  let ones = co2s.filter(proc(x: uint): bool = mask.bitand(x) > 0).len

  if 2 * ones >= co2s.len:
    co2s = co2s.filter(proc(x: uint): bool = mask.bitand(x) > 0)
  else:
    co2s = co2s.filter(proc(x: uint): bool = mask.bitand(x) == 0)

for bit in countdown(data[0].high, data[0].low):
  if oxygens.len == 1:
    break

  let mask: uint = 1u.rotateLeftBits(bit)

  let zeros = oxygens.filter(proc(x: uint): bool = mask.bitand(x) == 0).len

  if 2 * zeros <= oxygens.len:
    oxygens = oxygens.filter(proc(x: uint): bool = mask.bitand(x) == 0)
  else:
    oxygens = oxygens.filter(proc(x: uint): bool = mask.bitand(x) > 0)

echo co2s[0] * oxygens[0]
