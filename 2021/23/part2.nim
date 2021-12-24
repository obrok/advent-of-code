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

proc valid(x: int, y: int, from_x: int, from_y: int, letter: char, letter_under: char): bool =
  if (x, y) in [(1, 1), (1, 2), (1, 4), (1, 6), (1, 8), (1, 10), (1, 11)]:
    from_x != 1
  elif x in [2, 3, 4, 5] and y == (int(letter) - int('A')) * 2 + 3:
    from_x == 1 and (letter_under == '#' or letter_under == letter)
  else:
    false

let costs = {'A': 1, 'B': 10, 'C': 100, 'D': 1000}.toTable
proc cost(letter: char): int =
  costs[letter]

iterator moves(map: seq[string]): (int, seq[string]) =
  var map2 = map
  for i in 0 .. map.high:
    for j in 0 .. map[i].high:
      if map[i][j] in ['A', 'B', 'C', 'D']:
        var q = [(0, i, j)].toHeapQueue
        var visited = initHashSet[(int, int)]()
        while q.len > 0:
          let next = q.pop
          let (c, x, y) = next
          if not visited.contains((x, y)):
            visited.incl((x, y))
            map2[i][j] = '.'
            map2[x][y] = map[i][j]
            if c > 0 and valid(x, y, i, j, map[i][j], map2[x+1][y]):
              yield (c, map2)
            map2[i][j] = map[i][j]
            map2[x][y] = map[x][y]
            for (nx, ny) in [(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)]:
              if map[nx][ny] == '.':
                q.push((c + cost(map[i][j]), nx, ny))

proc done(map: seq[string]): bool =
  for letter in ['A', 'B', 'C', 'D']:
    for x in [2, 3, 4, 5]:
      if map[x][(int(letter) - int('A')) * 2 + 3] != letter:
        return false
  return true

proc `<`(a: (int, seq[string]), b: (int, seq[string])): bool =
    a[0] < b[0]

let map = stdin.readAll.strip(chars = {'\n'}).split("\n")

var q = [(cost: 0, map: map)].toHeapQueue
var visited = initHashSet[seq[string]]()

while not q[0].map.done:
  let next = q.pop

  if not visited.contains(next.map):
    visited.incl(next.map)
    for (c, m) in moves(next.map):
      q.push((next.cost + c, m))

echo q[0].cost
