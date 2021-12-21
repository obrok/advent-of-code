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

type Game = tuple[p1: int, p2: int, s1: int, s2: int, rolls: int]

proc inc_mod(x: var int, n: int): int =
  result = x + 1
  x = (x + 1) mod n

proc step(game: Game): Game =
  var die = game.rolls
  let p1_roll = die.inc_mod(100) + die.inc_mod(100) + die.inc_mod(100)
  let p2_roll = die.inc_mod(100) + die.inc_mod(100) + die.inc_mod(100)
  let p1 = (game.p1 + p1_roll) mod 10
  let p2 = (game.p2 + p2_roll) mod 10
  let s1 = game.s1 + p1 + 1
  if s1 >= 1000:
    (p1, p2, s1, game.s2, game.rolls + 3)
  else:
    (p1, p2, s1, game.s2 + p2 + 1, game.rolls + 6)

let player1 = stdin.readLine.split(": ")[1].parseInt - 1
let player2 = stdin.readLine.split(": ")[1].parseInt - 1
var game: Game = (player1, player2, 0, 0, 0)

while game.s1 < 1000 and game.s2 < 1000:
  game = game.step

echo min(game.s1, game.s2) * game.rolls
