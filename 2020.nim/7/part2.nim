import strutils
import sequtils
import tables
import strscans
import sets

proc parseLine(line: string): seq[(string, int, string)] =
  let parts = line.split(" bags contain ")
  parts[1].strip(chars = {'.'}).split(", ").map(proc(x: string): (string, int, string) =
    var count: int
    var bag: string
    discard scanf(x, "$i $+ bag", count, bag)
    (parts[0], count, bag.strip(leading=false, chars={'s'})))

var graph = initTable[string, seq[(string, int)]]()

for line in stdin.readAll().strip().split("\n"):
  for (container, count, contained) in parseLine(line):
    if not graph.hasKey(container):
      graph[container] = @[]
    graph[container].add((contained, count))

proc weight(node: string): int =
  graph.getOrDefault(node, @[]).mapIt(it[1] * weight(it[0])).foldl(a + b, 1)

echo weight("shiny gold") - 1
