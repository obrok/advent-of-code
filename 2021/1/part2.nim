import sequtils
import strutils

let data = stdin.readAll().strip().splitLines().map(parseInt)

var last = data[0] + data[1] + data[2]
var result = 0

for i in 3..(data.len - 1):
  let next = last - data[i - 3] + data[i]
  if next > last:
    result += 1
  last = next

echo result
