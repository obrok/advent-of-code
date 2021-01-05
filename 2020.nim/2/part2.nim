import strscans
import strutils

var valid = 0

for line in stdin.readAll().split("\n"):
  if line == "":
    break

  var lo, hi: int
  var c, password: string

  discard scanf(line, "$i-$i $+: $+", lo, hi, c, password)

  if password[lo - 1] == c[0] xor password[hi - 1] == c[0]:
    valid += 1

echo valid
