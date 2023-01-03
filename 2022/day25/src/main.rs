fn main() {
    let sum = std::io::stdin()
        .lines()
        .map(|l| parse(&l.unwrap()))
        .sum::<i64>();
    println!("Part1: {}", unparse(sum));
}

fn unparse(mut n: i64) -> String {
    let mut s = String::new();

    while n > 0 {
        let (digit, value) = match n % 5 {
            0 => ('0', 0),
            1 => ('1', 1),
            2 => ('2', 2),
            3 => ('=', -2),
            4 => ('-', -1),
            _ => unreachable!(),
        };
        n -= value;
        s.push(digit);
        n /= 5
    }

    s.chars().rev().collect()
}

fn parse(line: &str) -> i64 {
    let chars = line.chars().collect::<Vec<_>>();
    let mut total = 0;

    for c in chars {
        total *= 5;
        match c {
            '2' => total += 2,
            '1' => total += 1,
            '0' => total += 0,
            '-' => total -= 1,
            '=' => total -= 2,
            _ => panic!("Invalid character"),
        }
    }

    total
}
