use std::io::stdin;

fn main() {
    let mut stacks = vec![
        "CFBLDPZS".chars().rev().collect::<Vec<_>>(),
        "BWHPGVN".chars().rev().collect(),
        "GJBWF".chars().rev().collect(),
        "SCWLFNJG".chars().rev().collect(),
        "HSMPTLJW".chars().rev().collect(),
        "SFGWCB".chars().rev().collect(),
        "WBQMPTH".chars().rev().collect(),
        "TWSF".chars().rev().collect(),
        "RCN".chars().rev().collect(),
    ];
    let mut instructions = vec![];

    for line in stdin().lines().map(|x| x.unwrap()) {
        let parts = line.split_whitespace().collect::<Vec<_>>();
        let quantity = parts[1].parse().unwrap();
        let from = parts[3].parse::<usize>().unwrap();
        let to = parts[5].parse::<usize>().unwrap();
        instructions.push((quantity, from, to));
    }

    let mut stacks2 = stacks.clone();

    for (q, from, to) in instructions.iter() {
        for _ in 0..*q {
            let c = stacks[from - 1].pop().unwrap();
            stacks[to - 1].push(c);
        }
    }

    println!(
        "Part1: {}",
        stacks.iter().map(|x| x[x.len() - 1]).collect::<String>()
    );

    for (q, from, to) in instructions.iter() {
        let mut temp = vec![];
        for _ in 0..*q {
            let c = stacks2[from - 1].pop().unwrap();
            temp.push(c);
        }
        while let Some(x) = temp.pop() {
            stacks2[to - 1].push(x);
        }
    }

    println!(
        "Part2: {}",
        stacks2.iter().map(|x| x[x.len() - 1]).collect::<String>()
    )
}
