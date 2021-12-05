import sequtils
import strutils
import parseutils
import bitops
import sets

proc parseBoard(input: string): seq[seq[int]] =
  return input.strip().split("\n").
    map(proc(line: string): seq[int] =
      line.split(" ").
        filterIt(not it.isEmptyOrWhitespace()).
        map(parseInt))

proc wins(board: seq[seq[int]], drawn: HashSet[int]): bool =
  for x in board.low .. board.high:
    if (board.low .. board.high).mapIt(board[x][it]).allIt(drawn.contains(it)):
      return true
    if (board.low .. board.high).mapIt(board[it][x]).allIt(drawn.contains(it)):
      return true

  return false

proc doScore(board:seq[seq[int]], drawn: HashSet[int]): int =
  result = 0
  for row in board:
    for x in row:
      if not drawn.contains(x):
        result += x

proc score(board: seq[seq[int]], drawOrder: seq[int]): tuple[winsAt: int, score: int] =
  var drawn = initHashSet[int]()
  for draw in drawOrder:
    drawn.incl(draw)
    if wins(board, drawn):
      return (drawn.len, draw * doScore(board, drawn))
  return (drawn.len + 1, 0)

let drawOrder = stdin.readLine().split(",").map(parseInt)
discard stdin.readLine()
let boards = stdin.readAll().split("\n\n").map(parseBoard)
let scores = boards.mapIt(score(it, drawOrder))

echo scores[scores.minIndex].score
echo scores[scores.maxIndex].score

