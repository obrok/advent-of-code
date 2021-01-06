import strutils
import strscans
import sequtils
import tables
import sugar
import re

proc parseFields(passport: string): Table[string, string] =
  passport.split("\n").join(" ").split().
    mapIt(it.split(":")).mapIt((it[0], it[1])).toTable()

let keys = ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]
let eyeColors = ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]

stdin.readAll().strip().split("\n\n").
  map(parseFields).
  filterIt(keys.all(key => it.hasKey(key))).
  countIt(
    block:
      it["byr"] >= "1920" and it["byr"] <= "2002" and
        it["iyr"] >= "2010" and it["iyr"] <= "2020" and
        it["eyr"] >= "2020" and it["eyr"] <= "2030" and
        it["hgt"].contains(re"^(1(([5-8][0-9])|(9[0-3]))cm)|((59|6[0-9]|7[0-6])in)$") and
        it["hcl"].contains(re"^#[0-9a-f]{6}$") and
        eyeColors.contains(it["ecl"]) and
        it["pid"].contains(re"^[0-9]{9}$")
  ).echo
