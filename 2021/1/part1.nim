import sequtils
import strutils

let data = stdin.readAll().strip().splitLines().map(parseInt)

var result = 0
for i in 1..(data.len - 1):
  if data[i-1] < data[i]:
    result += 1

echo result
