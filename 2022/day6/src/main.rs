use std::collections::HashSet;
use std::io::stdin;

fn main() {
    let data = stdin()
        .lines()
        .next()
        .unwrap()
        .unwrap()
        .chars()
        .collect::<Vec<_>>();

    println!("Part1: {}", find_start(&data, 4));
    println!("Part2: {}", find_start(&data, 14));
}

fn find_start(data: &[char], marker_size: usize) -> usize {
    for pos in 0..data.len() {
        if data[pos..(pos + marker_size)]
            .iter()
            .collect::<HashSet<_>>()
            .len()
            == marker_size
        {
            return pos + marker_size;
        }
    }

    panic!("No start found");
}
