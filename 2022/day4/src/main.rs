use std::cmp::{max, min};
use std::io::stdin;

type Elf = (u32, u32);

fn main() {
    let mut pairs = vec![];

    for line in stdin().lines() {
        let line = line.unwrap();
        let elves = line.split(",").collect::<Vec<_>>();

        let e1 = parse_elf(elves[0]);
        let e2 = parse_elf(elves[1]);
        pairs.push((e1, e2));
    }

    let mut total = 0;
    let mut partial = 0;
    for pair in pairs {
        match intersection(&pair.0, &pair.1) {
            None => (),
            Some(i) => {
                partial += 1;
                if i == pair.0 || i == pair.1 {
                    total += 1
                }
            }
        }
    }

    println!("Part1: {}", total);
    println!("Part2: {}", partial);
}

fn intersection(e1: &Elf, e2: &Elf) -> Option<Elf> {
    if e1.0 > e2.1 || e2.0 > e1.1 {
        None
    } else {
        Some((max(e1.0, e2.0), min(e1.1, e2.1)))
    }
}

fn parse_elf(elf: &str) -> Elf {
    let parts = elf.split("-").collect::<Vec<_>>();
    (parts[0].parse().unwrap(), parts[1].parse().unwrap())
}
