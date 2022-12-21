#![feature(option_zip)]

use sscanf::{sscanf, FromScanf};
use std::collections::HashMap;

#[derive(Debug, FromScanf)]
enum Op {
    #[sscanf(format = "{}")]
    Literal(i64),
    #[sscanf(format = "{} + {}")]
    Add(String, String),
    #[sscanf(format = "{} - {}")]
    Sub(String, String),
    #[sscanf(format = "{} * {}")]
    Mul(String, String),
    #[sscanf(format = "{} / {}")]
    Div(String, String),
}

fn main() {
    let monkeys = std::io::stdin()
        .lines()
        .map(|line| {
            let line = line.unwrap();
            sscanf!(line, "{String}: {Op}").unwrap()
        })
        .collect::<HashMap<_, _>>();

    println!("Part1: {}", eval(&monkeys, "root", |x| Some(x)).unwrap());
    println!("Part2: {}", solve(&monkeys, "root", 0));
}

fn solve(monkeys: &HashMap<String, Op>, monkey: &str, target: i64) -> i64 {
    if monkey == "root" {
        if let Op::Add(ref lhs, ref rhs) = monkeys[monkey] {
            let rhs = eval(monkeys, rhs, |_| None).unwrap();
            return solve(monkeys, lhs, rhs);
        }
    }

    match monkeys[monkey] {
        Op::Literal(_) => {
            if monkey == "humn" {
                return target;
            }
        }

        Op::Add(ref lhs, ref rhs) => {
            if let Some(x) = eval(monkeys, &lhs, |_| None) {
                return solve(monkeys, &rhs, target - x);
            }

            if let Some(x) = eval(monkeys, &rhs, |_| None) {
                return solve(monkeys, &lhs, target - x);
            }
        }

        Op::Sub(ref lhs, ref rhs) => {
            if let Some(x) = eval(monkeys, &lhs, |_| None) {
                return solve(monkeys, &rhs, x - target);
            }

            if let Some(x) = eval(monkeys, &rhs, |_| None) {
                return solve(monkeys, &lhs, target + x);
            }
        }

        Op::Mul(ref lhs, ref rhs) => {
            if let Some(x) = eval(monkeys, &lhs, |_| None) {
                return solve(monkeys, &rhs, target / x);
            }

            if let Some(x) = eval(monkeys, &rhs, |_| None) {
                return solve(monkeys, &lhs, target / x);
            }
        }

        Op::Div(ref lhs, ref rhs) => {
            if let Some(x) = eval(monkeys, &lhs, |_| None) {
                return solve(monkeys, &rhs, x / target);
            }

            if let Some(x) = eval(monkeys, &rhs, |_| None) {
                return solve(monkeys, &lhs, target * x);
            }
        }
    }

    panic!("No solution found for {:?}", monkeys[monkey]);
}

fn eval<F>(monkeys: &HashMap<String, Op>, monkey: &str, humn_val: F) -> Option<i64>
where
    F: Fn(i64) -> Option<i64> + Copy,
{
    if monkey == "humn" {
        if let Op::Literal(val) = monkeys[monkey] {
            return humn_val(val);
        }
    }

    match monkeys[monkey] {
        Op::Literal(value) => Some(value),
        Op::Add(ref a, ref b) => {
            eval(monkeys, a, humn_val).zip_with(eval(monkeys, b, humn_val), |a, b| a + b)
        }
        Op::Sub(ref a, ref b) => {
            eval(monkeys, a, humn_val).zip_with(eval(monkeys, b, humn_val), |a, b| a - b)
        }
        Op::Mul(ref a, ref b) => {
            eval(monkeys, a, humn_val).zip_with(eval(monkeys, b, humn_val), |a, b| a * b)
        }
        Op::Div(ref a, ref b) => {
            eval(monkeys, a, humn_val).zip_with(eval(monkeys, b, humn_val), |a, b| a / b)
        }
    }
}
