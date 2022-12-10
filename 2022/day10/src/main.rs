use sscanf::{sscanf, FromScanf};
use std::io::stdin;

#[derive(Debug, FromScanf)]
enum Op {
    #[sscanf("noop")]
    Noop,
    #[sscanf("addx {}")]
    Add(i32),
}

fn main() {
    let ops = stdin()
        .lines()
        .flat_map(|line| {
            let line = line.unwrap();
            match sscanf!(line, "{Op}").unwrap() {
                Op::Noop => vec![Op::Noop],
                Op::Add(x) => vec![Op::Noop, Op::Add(x)],
            }
        })
        .collect::<Vec<_>>();

    let mut cycle = 1;
    let mut sprite = 1i32;
    let mut total = 0;
    let mut crt = [[false; 40]; 6];

    for op in ops {
        if cycle % 40 == 20 {
            total += cycle * sprite;
        }

        if sprite.abs_diff((cycle - 1) % 40) <= 1 {
            crt[(cycle as usize - 1) / 40][(cycle as usize - 1) % 40] = true;
        }

        match op {
            Op::Noop => (),
            Op::Add(n) => sprite += n,
        }

        cycle += 1;
    }

    println!("Part1: {}", total);
    println!("Part2:");
    for i in 0..6 {
        for j in 0..40 {
            print!("{} ", if crt[i][j] { '#' } else { ' ' });
        }
        println!();
    }
}
