import sequtils
import strutils

let data = map(splitLines(strip(readAll(stdin))), parseInt)
for a in data:
  for b in data:
    if a + b == 2020:
      echo a * b
