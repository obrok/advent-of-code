#[derive(Debug, Clone)]
enum Op {
    Add(u64),
    Mul(u64),
    Square,
}

impl Op {
    fn apply(&self, to: u64) -> u64 {
        match *self {
            Self::Add(n) => to + n,
            Self::Mul(n) => to * n,
            Self::Square => to * to,
        }
    }
}

#[derive(Debug, Clone)]
struct Monkey {
    items: Vec<u64>,
    operation: Op,
    divisible: u64,
    if_true: usize,
    if_false: usize,
    inspected: u64,
}

fn main() {
    let monkeys = vec![
        Monkey {
            items: vec![93, 54, 69, 66, 71],
            operation: Op::Mul(3),
            divisible: 7,
            if_true: 7,
            if_false: 1,
            inspected: 0,
        },
        Monkey {
            items: vec![89, 51, 80, 66],
            operation: Op::Mul(17),
            divisible: 19,
            if_true: 5,
            if_false: 7,
            inspected: 0,
        },
        Monkey {
            items: vec![90, 92, 63, 91, 96, 63, 64],
            operation: Op::Add(1),
            divisible: 13,
            if_true: 4,
            if_false: 3,
            inspected: 0,
        },
        Monkey {
            items: vec![65, 77],
            operation: Op::Add(2),
            divisible: 3,
            if_true: 4,
            if_false: 6,
            inspected: 0,
        },
        Monkey {
            items: vec![76, 68, 94],
            operation: Op::Square,
            divisible: 2,
            if_true: 0,
            if_false: 6,
            inspected: 0,
        },
        Monkey {
            items: vec![86, 65, 66, 97, 73, 83],
            operation: Op::Add(8),
            divisible: 11,
            if_true: 2,
            if_false: 3,
            inspected: 0,
        },
        Monkey {
            items: vec![78],
            operation: Op::Add(6),
            divisible: 17,
            if_true: 0,
            if_false: 1,
            inspected: 0,
        },
        Monkey {
            items: vec![89, 57, 59, 61, 87, 55, 55, 88],
            operation: Op::Add(7),
            divisible: 5,
            if_true: 2,
            if_false: 5,
            inspected: 0,
        },
    ];

    println!("Part1: {}", run(monkeys.clone(), 20, 3));
    println!("Part2: {}", run(monkeys, 10000, 1));
}

fn run(mut monkeys: Vec<Monkey>, rounds: usize, reduction: u64) -> u64 {
    let m = monkeys.iter().map(|x| x.divisible).product::<u64>();
    for _ in 0..rounds {
        round(&mut monkeys, m, reduction);
    }
    monkeys.sort_by_key(|m| m.inspected);
    monkeys.reverse();

    monkeys[0].inspected * monkeys[1].inspected
}

fn round(monkeys: &mut Vec<Monkey>, m: u64, reduction: u64) {
    for i in 0..monkeys.len() {
        let items = std::mem::take(&mut monkeys[i].items);
        for item in items {
            monkeys[i].inspected += 1;
            let new_level = monkeys[i].operation.apply(item) / reduction % m;
            if new_level % monkeys[i].divisible == 0 {
                let if_true = monkeys[i].if_true;
                monkeys[if_true].items.push(new_level);
            } else {
                let if_false = monkeys[i].if_false;
                monkeys[if_false].items.push(new_level);
            }
        }
    }
}
