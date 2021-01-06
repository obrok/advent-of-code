import strutils
import sequtils

let map = stdin.readAll().strip().split("\n")

proc check(input: (int, int)): int =
  var (right, down) = input
  var x = 0
  var y = 0

  while x < map.len:
    if map[x][y] == '#': result += 1
    y = (y + right) mod map[x].len
    x += down

[(1, 1), (3, 1), (5, 1), (7, 1), (1, 2)].map(check).foldl(a * b).echo
