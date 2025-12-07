package main

import (
	"fmt"
	"os"
	"slices"
	"sort"
	"strconv"
	"strings"
)

func main() {
	smallInput := readFile("small_input.txt")
	smallInput2 := readFile("small_input2.txt")
	input := readFile("input.txt")

	fmt.Println("Part 1 small:", solve1(smallInput))
	fmt.Println("Part 1:", solve1(input))
	fmt.Println("Part 2 small:", solve2(smallInput))
	fmt.Println("Part 2 small 2:", solve2(smallInput2))
	fmt.Println("Part 2:", solve2(input))
}

func solve1(input string) int {
	res := 0

	for _, r := range strings.Split(input, ",") {
		parts := strings.Split(r, "-")
		lo := parseInt(parts[0])
		hi := parseInt(parts[1])

		for i := lo; i <= hi; i++ {
			mod := 1
			for d := 1; d <= len(strconv.Itoa(i))/2; d++ {
				mod *= 10
			}

			if i/mod == i%mod {
				res += i
			}
		}
	}

	return res
}

func solve2(input string) int {
	res := 0

	for _, r := range strings.Split(input, ",") {
		parts := strings.Split(r, "-")
		lo := parseInt(parts[0])
		hi := parseInt(parts[1])
		visited := map[int]bool{}

		for i := lo; i <= hi; i++ {
			if visited[i] {
				continue
			}
			visited[i] = true
			mod := 1
			for d := 1; d <= len(strconv.Itoa(i))/2; d++ {
				mod *= 10

				if len(strconv.Itoa(i))%d != 0 {
					continue
				}

				vals := []int{}
				for j := i; j > 0; j /= mod {
					vals = append(vals, j%mod)
				}
				sort.Ints(vals)
				vals = slices.Compact(vals)

				if len(vals) == 1 {
					res += i
					break
				}
			}
		}
	}

	return res
}

func parseInt(s string) int {
	n, err := strconv.Atoi(s)
	if err != nil {
		panic(err)
	}
	return n
}

func readFile(path string) string {
	data, err := os.ReadFile(path)
	if err != nil {
		panic(err)
	}

	data2 := string(data)
	return strings.TrimSpace(data2)
}
