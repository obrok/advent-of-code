package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

func main() {
	smallInput := readFile("small_input.txt")
	input := readFile("input.txt")

	fmt.Println("Part 1 small:", part1(smallInput))
	fmt.Println("Part 1:", part1(input))
	fmt.Println("Part 2 small:", part2(smallInput))
	fmt.Println("Part 2:", part2(input))
}

func part1(input string) int {
	lines := strings.Split(input, "\n")
	total := 0

	for _, line := range lines {
		chars := strings.Split(line, "")
		best := 0

		values := toIntSlice(chars)

		for i, x := range values {
			for _, y := range values[i+1:] {
				val := 10*x + y
				if val > best {
					best = val
				}
			}
		}

		total += best
	}

	return total
}

func part2(input string) int {
	lines := strings.Split(input, "\n")
	total := 0

	for _, line := range lines {
		chars := strings.Split(line, "")
		values := toIntSlice(chars)
		total += maxJoltage(values)
	}

	return total
}

func maxJoltage(values []int) int {
	maxes := make([][]int, len(values))

	for i := range values {
		maxes[i] = make([]int, 13)
		maxes[i][0] = 0
	}

	for i := 1; i < len(maxes[0]); i++ {
		maxes[len(values)-1][i] = values[len(values)-1]
	}

	for i := len(values) - 2; i >= 0; i-- {
		for j := 1; j < len(maxes[0]); j++ {
			option1 := maxes[i+1][j]
			option2 := maxes[i+1][j-1] + values[i]*pow(10, log(maxes[i+1][j-1]))
			maxes[i][j] = max(option1, option2)
		}
	}

	return maxes[0][12]
}

func readFile(filename string) string {
	f, err := os.ReadFile(filename)
	if err != nil {
		panic(err)
	}

	return strings.TrimSpace(string(f))
}

func toInt(s string) int {
	res, err := strconv.Atoi(s)
	if err != nil {
		panic(err)
	}

	return res
}

func toIntSlice(ss []string) []int {
	res := []int{}
	for _, s := range ss {
		res = append(res, toInt(s))
	}

	return res
}

func log(a int) int {
	res := 0
	for a > 0 {
		a /= 10
		res++
	}
	return res
}

func pow(a, b int) int {
	if b == 0 {
		return 1
	} else if b%2 == 0 {
		half := pow(a, b/2)
		return half * half
	} else {
		return a * pow(a, b-1)
	}
}
