use std::collections::HashSet;
use std::collections::VecDeque;
use std::io::stdin;

fn main() {
    let mut map = vec![];

    let mut start = (0, 0);
    let mut other_starts = vec![];

    for line in stdin().lines() {
        let line = line.unwrap();
        let mut row = vec![];

        for c in line.chars() {
            if c == 'S' {
                start = (map.len(), row.len());
            }
            if c == 'a' {
                other_starts.push((map.len(), row.len()));
            }
            row.push(c);
        }

        map.push(row);
    }

    println!("Part1: {:?}", search(&map, &vec![start]));
    println!("Part2: {:?}", search(&map, &other_starts));
}

fn search(map: &Vec<Vec<char>>, starts: &Vec<(usize, usize)>) -> usize {
    let mut visited = HashSet::new();
    let mut queue = VecDeque::from(starts.iter().map(|x| (0, *x)).collect::<Vec<_>>());

    while !queue.is_empty() {
        let (dist, (x, y)) = queue.pop_front().unwrap();
        if visited.contains(&(x, y)) {
            continue;
        }

        if map[x][y] == 'E' {
            return dist;
        }

        visited.insert((x, y));
        for (a, b) in vec![
            (x.saturating_sub(1), y),
            (x + 1, y),
            (x, y.saturating_sub(1)),
            (x, y + 1),
        ] {
            if a < map.len() && b < map[0].len() {
                if passable(map[x][y], map[a][b]) {
                    queue.push_back((dist + 1, (a, b)));
                }
            }
        }
    }

    panic!("should not happen");
}

fn passable(a: char, b: char) -> bool {
    let a = height(a);
    let b = height(b);
    a + 1 >= b
}

fn height(a: char) -> usize {
    match a {
        'S' => 'a' as usize,
        'E' => 'z' as usize,
        other => other as usize,
    }
}
