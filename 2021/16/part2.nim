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

type Packet = ref object
  version: int
  type_id: int
  value: int
  children: seq[Packet]

type ParseResult[T] = tuple[res: T, pos: int]

proc bits(n: int): seq[int] =
  var n = n
  result = newSeq[int](4)
  for i in countdown(4, 1):
    result[i - 1] = n mod 2
    n = n div 2

proc number(bits: seq[int]): int =
  result = 0
  for i in bits.low .. bits.high:
    result *= 2
    result += bits[i]

proc parseLiteral(input: seq[int], pos: int, total: int): ParseResult[int] =
  let value = number(input[pos + 1 .. pos + 4])
  case input[pos]:
    of 0: return (res: total * 16 + value, pos: pos + 5)
    else: return parseLiteral(input, pos + 5, total * 16 + value)

proc parsePacket(input: seq[int], pos: int): ParseResult[Packet]

proc parseChildren(input: seq[int], pos: int, count: int): ParseResult[seq[Packet]] =
  var res = newSeq[Packet](count)
  var pos = pos
  for i in 1..count:
    let one = parsePacket(input, pos)
    res[i - 1] = one.res
    pos = one.pos
  return (res: res, pos: pos)

proc parseBits(input: seq[int], pos: int, count: int): ParseResult[seq[Packet]] =
  var res = newSeq[Packet](0)
  var newPos = pos
  while newPos < pos + count:
    let one = parsePacket(input, newPos)
    res.add(one.res)
    newPos = one.pos
  return (res: res, pos: newPos)


proc parsePacket(input: seq[int], pos: int): ParseResult[Packet] =
  let version = number(input[pos .. pos + 2])
  let type_id = number(input[pos + 3 .. pos + 5])
  case type_id:
    of 4:
      let temp = parseLiteral(input, pos + 6, 0)
      return (res: Packet(version: version, type_id: type_id, value: temp.res), pos: temp.pos)
    else:
      case input[pos + 6]:
        of 1:
          let nchildren = number(input[pos + 7 .. pos + 17])
          let children = parseChildren(input, pos + 18, nchildren)
          return (res: Packet(version: version, type_id: type_id, children: children.res), pos: children.pos)
        else:
          let bitchildren = number(input[pos + 7 .. pos + 21])
          let children = parseBits(input, pos + 22, bitchildren)
          return (res: Packet(version: version, type_id: type_id, children: children.res), pos: children.pos)

proc print(packet: Packet): string =
  &"({packet.type_id}, {packet.value}, [{packet.children.mapIt(it.print).join(\",\")}])"

proc totalVersion(packet: Packet): int =
  packet.version + packet.children.mapIt(it.totalVersion).foldl(a + b, 0)

proc compute(packet: Packet): int =
  case packet.type_id:
    of 0: return packet.children.mapIt(it.compute).foldl(a + b, 0)
    of 1: return packet.children.mapIt(it.compute).foldl(a * b, 1)
    of 2: return packet.children.mapIt(it.compute).foldl(min(a, b))
    of 3: return packet.children.mapIt(it.compute).foldl(max(a, b))
    of 4: return packet.value
    of 5:
      if packet.children[0].compute > packet.children[1].compute:
        return 1
      else:
        return 0
    of 6: 
      if packet.children[0].compute < packet.children[1].compute:
        return 1
      else:
        return 0
    of 7: 
      if packet.children[0].compute == packet.children[1].compute:
        return 1
      else:
        return 0
    else: raise

let input = stdin.readLine.strip.mapIt(
  if it >= 'A':
    int(it) - int('A') + 10
  else:
    int(it) - int('0')
  ).mapIt(bits(it)).concat

echo parsePacket(input, 0).res.compute
