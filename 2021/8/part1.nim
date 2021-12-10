import sequtils
import strutils
import parseutils
import bitops
import sets
import tables

echo stdin.readAll.strip().split("\n").
  map(proc (line: string): seq[string] = line.split(" | ")[1].split(" ")).
  concat.
  filter(proc (digit: string): bool = digit.len == 2 or digit.len == 3 or digit.len == 4 or digit.len == 7).
  len
