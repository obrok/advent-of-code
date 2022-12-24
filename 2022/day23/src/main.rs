use std::collections::HashMap;
use std::collections::HashSet;

fn main() {
    let mut map = HashSet::new();

    let mut y = 0i64;
    for line in std::io::stdin().lines().map(|l| l.unwrap()) {
        let mut x = 0i64;

        for c in line.chars() {
            if c == '#' {
                map.insert((x, y));
            }

            x += 1;
        }

        y += 1;
    }

    let mut round = 0;
    loop {
        let mut no_proposed = HashMap::new();
        for &elf in map.iter() {
            if let Some(proposed) = propose_move(elf, &map, round) {
                *(no_proposed.entry(proposed).or_insert(0)) += 1;
            }
        }

        let mut new_map = HashSet::new();
        for &elf in map.iter() {
            match propose_move(elf, &map, round) {
                Some(proposed) if no_proposed[&proposed] == 1 => new_map.insert(proposed),
                _ => new_map.insert(elf),
            };
        }

        if round == 10 {
            println!("Part1: {}", count_space(&map));
        }

        if new_map == map {
            println!("Part2: {}", round + 1);
            break;
        }

        map = new_map;

        round += 1;
    }
}

fn count_space(map: &HashSet<(i64, i64)>) -> usize {
    let mut count = 0;
    for y in map.iter().map(|&(_, y)| y).min().unwrap()..=map.iter().map(|&(_, y)| y).max().unwrap()
    {
        for x in
            map.iter().map(|&(x, _)| x).min().unwrap()..=map.iter().map(|&(x, _)| x).max().unwrap()
        {
            if !map.contains(&(x, y)) {
                count += 1;
            }
        }
    }

    count
}

fn propose_move(elf: (i64, i64), map: &HashSet<(i64, i64)>, round: usize) -> Option<(i64, i64)> {
    let mut elfs = 0;
    for dx in -1..=1 {
        for dy in -1..=1 {
            if map.contains(&(elf.0 + dx, elf.1 + dy)) {
                elfs += 1;
            }
        }
    }

    if elfs == 1 {
        return None;
    }

    let dirs = [
        ((0, -1), (1, -1), (-1, -1)),
        ((0, 1), (1, 1), (-1, 1)),
        ((-1, 0), (-1, 1), (-1, -1)),
        ((1, 0), (1, 1), (1, -1)),
    ];

    for i in 0..4 {
        let i = (i + round) % dirs.len();
        let (dir, n1, n2) = dirs[i];
        if !map.contains(&(elf.0 + dir.0, elf.1 + dir.1))
            && !map.contains(&(elf.0 + n1.0, elf.1 + n1.1))
            && !map.contains(&(elf.0 + n2.0, elf.1 + n2.1))
        {
            return Some((elf.0 + dir.0, elf.1 + dir.1));
        }
    }

    None
}
