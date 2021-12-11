import sequtils
import strutils
import parseutils
import bitops
import sets
import tables
import options
import algorithm

let matches = {'(': ')', '[': ']', '<': '>', '{': '}'}.toTable
let scores = {')': 1, ']': 2, '}': 3, '>': 4}.toTable

proc tryParse(line: string): Option[seq[char]] =
  var stack = newSeq[char]()
  for c in line:
    if {'(', '[', '<', '{'}.contains(c):
      stack.add(c)
    else:
      if matches[stack.pop] != c:
        return none(seq[char])
  return some(stack)

proc totalScore(cs: seq[char]): int =
  result = 0
  for x in cs.reversed:
    result *= 5
    result += scores[matches[x]]

var lineScores = newSeq[int]()
for line in stdin.readAll.strip.split("\n"):
  let res = tryParse(line)
  if res.isSome:
    lineScores.add(totalScore(res.unsafeGet))

sort(lineScores)

echo lineScores[lineScores.high div 2]
