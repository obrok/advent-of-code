use std::io::stdin;

fn main() {
    let mut elves = vec![];
    let mut current_elf = 0;

    for line in stdin().lines() {
        match line.unwrap().parse::<u32>() {
            Ok(calories) => current_elf += calories,
            Err(_) => {
                elves.push(current_elf);
                current_elf = 0
            }
        }
    }

    elves.push(current_elf);
    elves.sort();
    elves.reverse();

    println!("Max: {}", elves[0]);
    println!("Top 3: {}", elves[0] + elves[1] + elves[2]);
}
