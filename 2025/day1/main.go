package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

func main() {
	smallInput, err := os.ReadFile("./small_input.txt")
	if err != nil {
		panic(err)
	}

	input, err := os.ReadFile("./input.txt")
	if err != nil {
		panic(err)
	}

	fmt.Println("Part 1 small:", solve1(smallInput))
	fmt.Println("Part1:", solve1(input))
	fmt.Println("Part 2 small:", solve2(smallInput))
	fmt.Println("Part 2:", solve2(input))
}

func solve1(smallInput []byte) int {
	moves := parseInput(smallInput)

	start := 50
	mod := 100
	res := 0

	for _, move := range moves {
		start = (start + move + mod) % mod
		if start == 0 {
			res += 1
		}
	}

	return res
}

func solve2(smallInput []byte) int {
	moves := parseInput(smallInput)

	start := 50
	mod := 100
	res := 0

	for _, move := range moves {
		if move > 0 {
			res += (start + move) / mod
		} else {
			extra := abs((start + move - mod) / mod)
			if start == 0 {
				extra -= 1
			}
			res += extra
		}

		start = ((start+move)%mod + mod) % mod
	}

	return res
}

func parseInput(input []byte) []int {
	lines := strings.Split(string(input), "\n")
	moves := []int{}

	for _, line := range lines {
		if line == "" {
			continue
		}

		number, err := strconv.Atoi(line[1:])
		if err != nil {
			panic(err)
		}

		if line[0] == 'L' {
			moves = append(moves, -number)
		} else {
			moves = append(moves, number)
		}
	}

	return moves
}

func abs(a int) int {
	return max(a, -a)
}
