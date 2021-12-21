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

type Game = tuple[p1: int, p2: int, s1: int, s2: int, turn: int]

var cache = newTable[Game, (int, int)]()

proc wins(game: Game): (int, int) =
  if game.s1 >= 21:
    return (1, 0)

  if game.s2 >= 21:
    return (0, 1)

  if not cache.hasKey(game):
    var p1_wins = 0
    var p2_wins = 0
    for r1 in 1..3:
      for r2 in 1..3:
        for r3 in 1..3:
          let roll = r1 + r2 + r3
          let subgame =
            if game.turn == 0:
              let p1 = (game.p1 + roll) mod 10
              (p1, game.p2, game.s1 + p1 + 1, game.s2, 1 - game.turn)
            else:
              let p2 = (game.p2 + roll) mod 10
              (game.p1, p2, game.s1, game.s2 + p2 + 1, 1 - game.turn)
          let res = wins(subgame)
          p1_wins += res[0]
          p2_wins += res[1]
    cache[game] = (p1_wins, p2_wins)

  return cache[game]

let player1 = stdin.readLine.split(": ")[1].parseInt - 1
let player2 = stdin.readLine.split(": ")[1].parseInt - 1
var game: Game = (player1, player2, 0, 0, 0)

let w = wins(game)
echo max(w[0], w[1])
