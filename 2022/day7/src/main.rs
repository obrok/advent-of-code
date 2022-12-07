use sscanf::{sscanf, FromScanf};
use std::collections::HashMap;
use std::io::stdin;

#[derive(Debug, FromScanf)]
enum Line {
    #[sscanf(format = "$ cd ..")]
    CdUp,
    #[sscanf(format = "$ cd {dir}")]
    Cd { dir: String },
    #[sscanf(format = "$ ls")]
    Ls,
    #[sscanf(format = "dir {_name}")]
    Dir { _name: String },
    #[sscanf(format = "{size} {_name}")]
    File { size: usize, _name: String },
}

fn main() {
    let input = stdin()
        .lines()
        .map(|line| {
            let line = line.unwrap();
            sscanf!(line, "{Line}").unwrap()
        })
        .collect::<Vec<_>>();

    let mut path = vec![];
    let mut dirs = HashMap::new();

    for line in input {
        match line {
            Line::CdUp => {
                path.pop();
            }
            Line::Cd { dir } => path.push(dir),
            Line::Ls => (),
            Line::Dir { .. } => (),
            Line::File { size, .. } => {
                for i in 1..(path.len() + 1) {
                    let path = path[0..i].join("/");
                    let entry = dirs.entry(path).or_insert(0);
                    *entry += size;
                }
            }
        }
    }

    let mut total = 0;
    for (_, &size) in &dirs {
        if size <= 100000 {
            total += size;
        }
    }
    println!("Part1: {}", total);

    let total_system_space = 70000000;
    let needed_space = 30000000;
    let min_delete = needed_space - (total_system_space - dirs["/"]);
    let best = dirs
        .iter()
        .map(|(_, &size)| size)
        .filter(|&size| size > min_delete)
        .min()
        .unwrap();
    println!("Part2: {}", best);
}
