use std::{collections::HashMap, io::stdin};

#[derive(Clone, Debug, PartialEq, Eq)]
enum Tile {
    Rock,
    Sand,
}

type Point = (i32, i32);

fn main() {
    let mut input = vec![];
    for line in stdin().lines() {
        let line = line.unwrap();
        let points = line
            .split(" -> ")
            .map(|p| {
                let p = p.split(",").map(|v| v.parse().unwrap()).collect::<Vec<_>>();
                (p[0], p[1])
            })
            .collect::<Vec<Point>>();
        input.push(points);
    }

    let mut map = HashMap::new();
    let mut bottom = 0;
    for line in input {
        for i in 0..(line.len() - 1) {
            for point in points(line[i], line[i + 1]) {
                map.insert(point, Tile::Rock);

                if point.1 > bottom {
                    bottom = point.1;
                }
            }
        }
    }

    part1(map.clone(), bottom);
    part2(map.clone(), bottom);
}

fn part1(mut map: HashMap<Point, Tile>, bottom: i32) {
    loop {
        let position = simulate(&map, bottom);
        if position.1 >= bottom {
            break;
        }
        map.insert(position, Tile::Sand);
    }

    println!(
        "Part1: {:?}",
        map.keys().filter(|p| map[p] == Tile::Sand).count()
    );
}

fn part2(mut map: HashMap<Point, Tile>, bottom: i32) {
    loop {
        let position = simulate(&map, bottom);
        map.insert(position, Tile::Sand);
        if position.1 == 0 {
            break;
        }
    }

    println!(
        "Part2: {:?}",
        map.keys().filter(|p| map[p] == Tile::Sand).count()
    );
}
fn points(from: Point, to: Point) -> Vec<Point> {
    if from.0 < to.0 {
        (from.0..(to.0 + 1)).map(|x| (x, from.1)).collect()
    } else if to.0 < from.0 {
        (to.0..(from.0 + 1)).map(|x| (x, from.1)).collect()
    } else if from.1 < to.1 {
        (from.1..(to.1 + 1)).map(|y| (from.0, y)).collect()
    } else {
        (to.1..(from.1 + 1)).map(|y| (from.0, y)).collect()
    }
}

fn simulate(map: &HashMap<Point, Tile>, bottom: i32) -> Point {
    let mut position = (500, 0);
    loop {
        if free(&map, below(position), bottom) {
            position = below(position);
        } else if free(&map, left(position), bottom) {
            position = left(position);
        } else if free(&map, right(position), bottom) {
            position = right(position);
        } else {
            return position;
        }
    }
}

fn free(map: &HashMap<Point, Tile>, pos: Point, bottom: i32) -> bool {
    if pos.1 >= bottom + 2 {
        return false;
    }

    map.get(&pos).is_none()
}

fn below(point: Point) -> Point {
    (point.0, point.1 + 1)
}

fn left(point: Point) -> Point {
    (point.0 - 1, point.1 + 1)
}

fn right(point: Point) -> Point {
    (point.0 + 1, point.1 + 1)
}
