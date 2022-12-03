use std::{collections::HashSet, io::stdin};

fn main() {
    let mut total = 0;
    let mut all: Vec<HashSet<char>> = vec![];

    for line in stdin().lines() {
        let line = line.unwrap();
        let mut pocket1 = line.chars().collect::<Vec<_>>();
        all.push(pocket1.clone().into_iter().collect());
        let pocket2 = pocket1.split_off(pocket1.len() / 2);
        let pocket1 = pocket1.into_iter().collect::<HashSet<_>>();
        let pocket2 = pocket2.into_iter().collect::<HashSet<_>>();

        let item = pocket1.intersection(&pocket2).cloned().next();

        let value: u32 = value(item.unwrap());
        total += value;
    }

    println!("Part1: {:?}", total);

    let mut total_badges = 0;
    for group in all.chunks(3) {
        let common = group[1].intersection(&group[2]).cloned().collect();
        let mut common = group[0].intersection(&common);
        let common = common.next().unwrap();
        total_badges += value(*common);
    }
    println!("Part2: {:?}", total_badges);
}

fn value(c: char) -> u32 {
    if c <= 'Z' {
        c as u32 - 'A' as u32 + 27
    } else {
        c as u32 - 'a' as u32 + 1
    }
}
