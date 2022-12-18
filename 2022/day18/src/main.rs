use sscanf::sscanf;
use std::collections::HashSet;

enum Explored {
    Inside(HashSet<(i32, i32, i32)>),
    Outside(HashSet<(i32, i32, i32)>),
}

fn main() {
    let points = std::io::stdin()
        .lines()
        .map(|line| {
            let line = line.unwrap();
            sscanf!(line, "{i32},{i32},{i32}").unwrap()
        })
        .collect::<HashSet<_>>();

    let min_x = points.iter().map(|p| p.0).min().unwrap();
    let max_x = points.iter().map(|p| p.0).max().unwrap();
    let min_y = points.iter().map(|p| p.1).min().unwrap();
    let max_y = points.iter().map(|p| p.1).max().unwrap();
    let min_z = points.iter().map(|p| p.2).min().unwrap();
    let max_z = points.iter().map(|p| p.2).max().unwrap();

    let mut inside = HashSet::new();
    let mut outside = HashSet::new();
    for x in min_x..=max_x {
        for y in min_y..=max_y {
            for z in min_z..=max_z {
                if !points.contains(&(x, y, z))
                    && !inside.contains(&(x, y, z))
                    && !outside.contains(&(x, y, z))
                {
                    match explore((x, y, z), &points, min_x, max_x, min_y, max_y, min_z, max_z) {
                        Explored::Inside(points) => {
                            inside.extend(points);
                        }
                        Explored::Outside(points) => {
                            outside.extend(points);
                        }
                    }
                }
            }
        }
    }

    let area: usize = points
        .iter()
        .map(|&p| neighbors(p).iter().filter(|&x| !points.contains(x)).count())
        .sum();

    let outside_area: usize = points
        .iter()
        .map(|&p| {
            neighbors(p)
                .iter()
                .filter(|&x| !points.contains(x) && !inside.contains(x))
                .count()
        })
        .sum();

    println!("Part1: {:?}", area);
    println!("Part2: {:?}", outside_area);
}

fn neighbors((x, y, z): (i32, i32, i32)) -> Vec<(i32, i32, i32)> {
    vec![
        (x - 1, y, z),
        (x + 1, y, z),
        (x, y - 1, z),
        (x, y + 1, z),
        (x, y, z - 1),
        (x, y, z + 1),
    ]
}

fn explore(
    point: (i32, i32, i32),
    points: &HashSet<(i32, i32, i32)>,
    min_x: i32,
    max_x: i32,
    min_y: i32,
    max_y: i32,
    min_z: i32,
    max_z: i32,
) -> Explored {
    let mut queue = vec![point];
    let mut visited = HashSet::new();

    while let Some(point) = queue.pop() {
        if points.contains(&point) {
            continue;
        } else if point.0 < min_x
            || point.0 > max_x
            || point.1 < min_y
            || point.1 > max_y
            || point.2 < min_z
            || point.2 > max_z
        {
            visited.insert(point);
            return Explored::Outside(visited);
        } else {
            visited.insert(point);
            queue.extend(
                neighbors(point)
                    .into_iter()
                    .filter(|x| !visited.contains(x)),
            );
        }
    }

    Explored::Inside(visited)
}
