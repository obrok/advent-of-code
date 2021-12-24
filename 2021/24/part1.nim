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

type
  TType = enum
    Register, Value
  Target = object
    case kind: TType
    of Register: n: int
    of Value: x: int

type
  IType = enum
    Inp, BinOp
  Instruction = object
    case kind: IType
    of Inp:
      target: Target
    of BinOp:
      op: string
      a: Target
      b: Target

proc parseTarget(reg: string): Target =
  case reg:
    of "x": Target(kind: Register, n: 0)
    of "y": Target(kind: Register, n: 1)
    of "z": Target(kind: Register, n: 2)
    of "w": Target(kind: Register, n: 3)
    else: Target(kind: Value, x: reg.parseInt)

proc parseLine(line: string): Instruction =
  let parts = line.split(" ")
  case parts[0]:
    of "inp": return Instruction(kind: Inp, target: parts[1].parseTarget)
    else: return Instruction(kind: BinOp, op: parts[0], a: parts[1].parseTarget, b: parts[2].parseTarget)

proc unparse(target: Target): string =
  case target.kind:
    of Register: ["x", "y", "z", "w"][target.n]
    of Value: $target.x

proc unparse(instruction: Instruction): string =
  case instruction.kind:
    of Inp: "inp $1" % [unparse(instruction.target)]
    of BinOp: "$1 $2 $3" % [instruction.op, instruction.a.unparse, instruction.b.unparse]

proc get(state: seq[int], target: Target): int =
  case target.kind:
    of Register: state[target.n]
    of Value: target.x

proc perform(op: string, a: int, b: int): int =
  case op:
    of "add": return a + b
    of "mul": return a * b
    of "div": return a div b
    of "mod": return a mod b
    of "eql": return if a == b: 1 else: 0

proc execute(state: var seq[int], instruction: Instruction, input: int) =
  case instruction.kind:
    of Inp: state[instruction.target.n] = input
    of BinOp:
      state[instruction.a.n] = perform(instruction.op, state[instruction.a.n], get(state, instruction.b))

proc run(state: var seq[int], program: seq[Instruction], input: int) =
  for instruction in program:
    execute(state, instruction, input)

proc emulate(digits: seq[int], params: seq[(int, int, int)]): int =
  for i, (d, ps) in zip(digits, params):
    let (p1, p2, p3) = ps
    let r = result mod 26
    result = result div p3
    if r + p1 != d:
      result = result * 26 + d + p2
    echo result

let instructions = stdin.readAll.strip.split("\n").map(parseLine)
var parts = newSeq[seq[Instruction]]()

var s = 0
for i in 1..14:
  var e = s + 1
  while e <= instructions.high and instructions[e].kind != Inp:
    e += 1
  parts.add(instructions[s .. (e - 1)])
  s = e

let to_optimize = (0..13).toSeq.filter(x => parts[x][5].b.x <= 0)
let to_maximize = (0..13).toSeq.filter(x => parts[x][5].b.x >= 0)

let params = collect:
  for i, part in parts:
    (part[5].b.x, part[^3].b.x, part[4].b.x)

let digits = @[1, 1, 9, 1, 2, 8, 1, 4, 6, 1, 1, 1, 5, 6]
echo emulate(digits, params)

var state = @[0, 0, 0, 0]
for (d, p) in zip(digits, parts):
  run(state, p, d)
  echo state
echo state

echo params
echo digits.map(x => $x).join("")
