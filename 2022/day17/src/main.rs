use std::cmp::max;
use std::collections::HashSet;
use std::io::stdin;

type Grid = HashSet<(i64, i64)>;

fn main() {
    let mut pattern = vec![];
    for c in stdin().lines().next().unwrap().unwrap().chars() {
        match c {
            '>' => pattern.push(1),
            '<' => pattern.push(-1),
            c => panic!("Invalid character {:?}", c),
        }
    }

    println!("Part1: {}", simulate(&pattern, 2022));
    println!("Part2: {}", simulate(&pattern, 1000000000000));
}

fn simulate(pattern: &Vec<i64>, steps: i64) -> i64 {
    let mut grid = HashSet::new();
    let mut max_height = 0;
    for x in 0..7 {
        grid.insert((x, 0));
    }
    let mut shape = [0i64; 7];

    let mut spawn_timer = 0i64;
    let mut wind_timer = 0i64;

    let mut visited = HashSet::new();
    let mut cycle_start = None;
    let mut cycle_length = None;
    let mut cycle_size = None;
    let mut extra_height = 0;

    while spawn_timer < steps {
        let spawn_index = spawn_timer % 5;
        let mut rock = spawn(spawn_index, max_height);

        let key = (
            shape.clone(),
            spawn_index,
            wind_timer % pattern.len() as i64,
        );

        if visited.contains(&key) && cycle_length.is_none() {
            if cycle_start.is_none() {
                cycle_start = Some(spawn_timer);
                cycle_size = Some(max_height);
                visited = HashSet::new();
            } else {
                cycle_length = Some(spawn_timer - cycle_start.unwrap());
                cycle_size = Some(max_height - cycle_size.unwrap());
                let cycles = (steps - cycle_start.unwrap()) / cycle_length.unwrap() - 1;
                spawn_timer += cycles * cycle_length.unwrap();
                extra_height = cycles * cycle_size.unwrap();
            }
        }
        visited.insert(key);

        loop {
            let wind_index = (wind_timer % pattern.len() as i64) as usize;

            let new_rock = move_side(&rock, pattern[wind_index]);
            if is_valid(&new_rock, &grid) {
                rock = new_rock;
            }
            wind_timer += 1;

            let new_rock = move_down(&rock);
            if !is_valid(&new_rock, &grid) {
                max_height = max(max_height, *rock.iter().map(|(_, y)| y).max().unwrap());
                for (x, y) in rock {
                    grid.insert((x, y));
                    shape[x as usize] = max_height - y;
                }
                break;
            } else {
                rock = new_rock
            }
        }
        spawn_timer += 1;
    }

    max_height + extra_height
}

fn is_valid(rock: &Vec<(i64, i64)>, grid: &Grid) -> bool {
    for (x, y) in rock {
        if *x < 0 || *x >= 7 {
            return false;
        }

        if grid.contains(&(*x, *y)) {
            return false;
        }
    }

    true
}

fn move_side(rock: &Vec<(i64, i64)>, dx: i64) -> Vec<(i64, i64)> {
    rock.iter().map(|(x, y)| (x + dx, *y)).collect()
}

fn move_down(rock: &Vec<(i64, i64)>) -> Vec<(i64, i64)> {
    rock.iter().map(|(x, y)| (*x, y - 1)).collect()
}

fn spawn(spawn_index: i64, max_height: i64) -> Vec<(i64, i64)> {
    match spawn_index % 5 {
        0 => vec![
            (2, max_height + 4),
            (3, max_height + 4),
            (4, max_height + 4),
            (5, max_height + 4),
        ],
        1 => vec![
            (3, max_height + 4),
            (2, max_height + 5),
            (3, max_height + 5),
            (4, max_height + 5),
            (3, max_height + 6),
        ],
        2 => vec![
            (2, max_height + 4),
            (3, max_height + 4),
            (4, max_height + 4),
            (4, max_height + 5),
            (4, max_height + 6),
        ],
        3 => vec![
            (2, max_height + 4),
            (2, max_height + 5),
            (2, max_height + 6),
            (2, max_height + 7),
        ],
        4 => vec![
            (2, max_height + 4),
            (3, max_height + 4),
            (2, max_height + 5),
            (3, max_height + 5),
        ],
        _ => unreachable!(),
    }
}
