import sequtils
import strutils
import parseutils
import bitops
import sets
import tables
import options

let matches = {'(': ')', '[': ']', '<': '>', '{': '}'}.toTable
let scores = {')': 3, ']': 57, '}': 1197, '>': 25137}.toTable

proc tryParse(line: string): Option[char] =
  var stack = newSeq[char]()
  for c in line:
    if {'(', '[', '<', '{'}.contains(c):
      stack.add(c)
    else:
      if matches[stack.pop] != c:
        return some(c)
  return none(char)

var total = 0
for line in stdin.readAll.strip.split("\n"):
  let res = tryParse(line)
  if res.isSome:
    total += scores[res.unsafeGet]

echo total
