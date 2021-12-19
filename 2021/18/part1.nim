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

type Number = ref object
  le: Number
  ri: Number
  val: int

proc print(number: Number): string = 
  if number.le != nil:
    "[$1,$2]" % [number.le.print, number.ri.print]
  else:
    number.val.intToStr

proc parseLine(line: string): Number =
  var st = initDeque[Number]()
  for c in line:
    if c == '[':
      discard
    elif c == ']':
      let ri = st.popFirst()
      let le = st.popFirst()
      st.addFirst(Number(le: le, ri: ri))
    elif c == ',':
      discard
    else:
      st.addFirst(Number(val: int(c) - int('0')))

  assert st.len == 1
  return st[0]

proc addLeft(number: Number, x: int): Number =
  if x == 0:
    return number
  elif number.le == nil:
    return Number(val: number.val + x)
  else:
    return Number(le: number.le.addLeft(x), ri: number.ri)

proc addRight(number: Number, x: int): Number =
  if x == 0:
    return number
  elif number.le == nil:
    return Number(val: number.val + x)
  else:
    return Number(ri: number.ri.addRight(x), le: number.le)

proc explode(number: Number, depth: int): Option[tuple[res: Number, le: int, ri: int]] =
  if number.le == nil:
    return none[tuple[res: Number, le: int, ri: int]]()
  elif number.le.le == nil and number.ri.le == nil and depth >= 4:
    return some((Number(val: 0), number.le.val, number.ri.val))
  else:
    let left = explode(number.le, depth + 1)
    if left.isSome:
      return some((Number(le: left.get.res, ri: addLeft(number.ri, left.get.ri)), left.get.le, 0))
    else:
      let right = explode(number.ri, depth + 1)
      if right.isSome:
        return some((Number(le: addRight(number.le, right.get.le), ri: right.get.res), 0, right.get.ri))

proc split(number: Number): Option[Number] =
  if number.le == nil and number.val >= 10:
    let le = number.val div 2
    let ri = number.val - le
    return some(Number(le: Number(val: le), ri: Number(val: ri)))
  elif number.le == nil:
    return none[Number]()
  else:
    let left = split(number.le)
    if left.isSome:
      return some(Number(le: left.get, ri: number.ri))
    else:
      let right = split(number.ri)
      if right.isSome:
        return some(Number(le: number.le, ri: right.get))
      else:
        return none[Number]()

proc reduce(number: Number): Number =
  let x = explode(number, 0)
  if x.isSome:
    return reduce(x.get.res)
  else:
    let y = split(number)
    if y.isSome:
      return reduce(y.get)
    else:
      return number

proc magnitude(number: Number): int =
  if number.le == nil:
    return number.val
  else:
    return 3 * number.le.magnitude + 2 * number.ri.magnitude

let numbers = stdin.readAll.strip.split("\n").mapIt(parseLine(it))
echo numbers.foldl(reduce(Number(le: a, ri: b))).magnitude
