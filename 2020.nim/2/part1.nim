import strscans
import strutils
import sequtils

var valid = 0

for line in stdin.readAll().split("\n"):
  if line == "":
    break

  var lo, hi: int
  var c, password: string

  discard scanf(line, "$i-$i $+: $+", lo, hi, c, password)

  let occurrences = password.count(c[0])
  if occurrences >= lo and occurrences <= hi:
    valid += 1

echo valid
