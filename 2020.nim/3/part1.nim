import strutils

let map = stdin.readAll().strip().split("\n")
var trees = 0
var pos = 0

for line in map:
  if line[pos] == '#': trees += 1
  pos = (pos + 3) mod line.len

echo trees
