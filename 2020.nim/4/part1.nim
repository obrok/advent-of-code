import strutils
import strscans
import sequtils
import tables
import sugar

proc parseFields(passport: string): Table[string, string] =
  passport.split("\n").join(" ").split().
    mapIt(it.split(":")).mapIt((it[0], it[1])).toTable()

let keys = ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]

stdin.readAll().strip().split("\n\n").map(parseFields).countIt(
  keys.all(key => it.hasKey(key))
).echo
