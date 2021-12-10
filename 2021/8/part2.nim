import sequtils
import strutils
import parseutils
import bitops
import sets
import tables

var total = 0

for line in stdin.readAll.strip().split("\n"):
  let left = line.split(" | ")[0].split(" ").mapIt(toHashSet(it))

  let one = left.filterIt(it.len == 2)[0]
  let seven = left.filterIt(it.len == 3)[0]
  let four = left.filterIt(it.len == 4)[0]
  let eight = left.filterIt(it.len == 7)[0]
  let three = left.filterIt(it.len == 5 and it * one == one)[0]
  let nine = left.filterIt(it.len == 6 and it * three == three)[0]
  let six = left.filterIt(it.len == 6 and it * one != one)[0]
  let zero = left.filterIt(it.len == 6 and it != nine and it != six)[0]
  let two = left.filterIt(it.len == 5 and it * one == eight - six)[0]
  let five = left.filterIt(it.len == 5 and it != three and it != two)[0]

  let values = {zero: 0, one: 1, two: 2, three: 3, four: 4, five: 5, six: 6, seven: 7, eight: 8, nine: 9}.toTable
  let digits = line.split(" | ")[1].split(" ").mapIt(values[toHashSet(it)])
  total += digits[0] * 1000 + digits[1] * 100 + digits[2] * 10 + digits[3]

echo total
