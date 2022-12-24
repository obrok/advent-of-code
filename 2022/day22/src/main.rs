use nom::character::complete::i64;
use nom::multi::many1;
use nom::IResult;
use std::collections::HashMap;
use std::io::stdin;

#[derive(Debug)]
enum Tile {
    Free,
    Wall,
}

#[derive(Debug)]
enum Move {
    Right,
    Left,
    Forward(i64),
}

type Coord = (i64, i64);

#[derive(Debug)]
struct Map {
    map: HashMap<(i64, i64), Tile>,
    min_x: HashMap<i64, i64>,
    max_x: HashMap<i64, i64>,
    min_y: HashMap<i64, i64>,
    max_y: HashMap<i64, i64>,
    face_size: i64,
    face_cache: HashMap<(Coord, Coord), (Coord, Rotation)>,
}

impl Map {
    fn walk(&self, (mut x, mut y): (i64, i64), dir: (i64, i64)) -> (Coord, Coord) {
        if dir.0 != 0 {
            x = x + dir.0;
            if x < self.min_x[&y] {
                x = self.max_x[&y];
            }

            if x > self.max_x[&y] {
                x = self.min_x[&y];
            }
        } else {
            y = y + dir.1;
            if y < self.min_y[&x] {
                y = self.max_y[&x];
            }

            if y > self.max_y[&x] {
                y = self.min_y[&x];
            }
        }

        ((x, y), dir)
    }

    fn walk_cube(&self, (x, y): Coord, (dx, dy): Coord) -> (Coord, Coord) {
        let (nx, ny) = (x + dx, y + dy);

        if self.face((nx, ny)) == self.face((x, y)) {
            ((nx, ny), (dx, dy))
        } else {
            let ((fx, fy), rot) = self.find_face(self.face((x, y)), (dx, dy));
            let (nx, ny) = self.translate((nx, ny), (fx, fy), rot);
            ((nx, ny), rotate_dir((dx, dy), rot.neg()))
        }
    }

    fn init_face_cache(&mut self) {
        for x in 0..4 {
            for y in 0..4 {
                let f = (x * self.face_size, y * self.face_size);
                for dir in [(-1, 0), (1, 0), (0, -1), (0, 1)] {
                    let n = (f.0 + dir.0 * self.face_size, f.1 + dir.1 * self.face_size);
                    if self.map.get(&f).is_some() && self.map.get(&n).is_some() {
                        self.face_cache.insert((f, dir), (n, Rotation::None));
                    }
                }
            }
        }

        while self.face_cache.len() < 24 {
            for x in 0..4 {
                for y in 0..4 {
                    for (next, next_dir, dir, rot) in [
                        ((-1, 0), (0, 1), (0, 1), Rotation::Left),
                        ((-1, 0), (0, -1), (0, -1), Rotation::Right),
                        ((1, 0), (0, 1), (0, 1), Rotation::Right),
                        ((1, 0), (0, -1), (0, -1), Rotation::Left),
                        ((0, -1), (1, 0), (1, 0), Rotation::Right),
                        ((0, -1), (-1, 0), (-1, 0), Rotation::Left),
                        ((0, 1), (1, 0), (1, 0), Rotation::Left),
                        ((0, 1), (-1, 0), (-1, 0), Rotation::Right),
                    ] {
                        let f = (x * self.face_size, y * self.face_size);
                        if self.map.get(&f).is_some() {
                            if let Some(&(next, rot2)) = self.face_cache.get(&(f, next)) {
                                if let Some(&(next, rot3)) = self
                                    .face_cache
                                    .get(&(next, rotate_dir(next_dir, rot2.neg())))
                                {
                                    self.face_cache.insert(
                                        (f, dir),
                                        (next, add_rot(rot, add_rot(rot2, rot3))),
                                    );
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    fn find_face(&self, f: Coord, d: Coord) -> (Coord, Rotation) {
        self.face_cache[&(f, d)]
    }

    fn translate(&self, coord: Coord, to_face: Coord, rot: Rotation) -> Coord {
        let (fx, fy) = self.face(coord);
        let (x, y) = (coord.0 - fx, coord.1 - fy);

        let (x, y) = match rot {
            Rotation::None => (x, y),
            Rotation::Left => (self.face_size - y - 1, x),
            Rotation::Right => (y, self.face_size - x - 1),
            Rotation::Flip => (self.face_size - x - 1, self.face_size - y - 1),
        };

        (x + to_face.0, y + to_face.1)
    }

    fn face(&self, (mut x, mut y): Coord) -> Coord {
        if x < 0 {
            x -= self.face_size;
        }

        if y < 0 {
            y -= self.face_size;
        }

        (
            x / self.face_size * self.face_size,
            y / self.face_size * self.face_size,
        )
    }
}

#[derive(Debug, Clone, Copy)]
enum Rotation {
    None,
    Left,
    Right,
    Flip,
}

impl Rotation {
    fn neg(&self) -> Rotation {
        match *self {
            Rotation::Left => Rotation::Right,
            Rotation::Right => Rotation::Left,
            other => other,
        }
    }
}

fn add_rot(rot1: Rotation, rot2: Rotation) -> Rotation {
    match (rot1, rot2) {
        (Rotation::None, rot) => rot,
        (rot, Rotation::None) => rot,
        (Rotation::Left, Rotation::Left) => Rotation::Flip,
        (Rotation::Right, Rotation::Right) => Rotation::Flip,
        (Rotation::Left, Rotation::Flip) => Rotation::Right,
        (Rotation::Right, Rotation::Flip) => Rotation::Left,
        (Rotation::Flip, Rotation::Left) => Rotation::Right,
        (Rotation::Flip, Rotation::Right) => Rotation::Left,
        _ => Rotation::None,
    }
}

fn rotate_dir((dx, dy): Coord, rot: Rotation) -> Coord {
    match rot {
        Rotation::None => (dx, dy),
        Rotation::Left => (dy, -dx),
        Rotation::Right => (-dy, dx),
        Rotation::Flip => rotate_dir(rotate_dir((dx, dy), Rotation::Left), Rotation::Left),
    }
}

fn parse_move(input: &str) -> IResult<&str, Move> {
    if input.starts_with("R") {
        Ok((&input[1..], Move::Right))
    } else if input.starts_with("L") {
        Ok((&input[1..], Move::Left))
    } else {
        let (input, num) = i64(input)?;
        Ok((input, Move::Forward(num as i64)))
    }
}

fn parse_moves(input: &str) -> IResult<&str, Vec<Move>> {
    many1(parse_move)(input)
}

fn main() {
    let mut map = Map {
        map: HashMap::new(),
        min_x: HashMap::new(),
        max_x: HashMap::new(),
        min_y: HashMap::new(),
        max_y: HashMap::new(),
        face_size: 0,
        face_cache: HashMap::new(),
    };
    let mut y = 0;
    let mut map_complete = false;
    let mut moves = vec![];

    for line in stdin().lines().map(|x| x.unwrap()) {
        if map_complete {
            (_, moves) = parse_moves(&line).unwrap();
            break;
        }

        if line == "" {
            map_complete = true
        } else {
            if line.len() > 20 {
                map.face_size = 50;
            } else {
                map.face_size = 4;
            }
        }

        let chars = line.chars().collect::<Vec<_>>();
        for x in 0..chars.len() {
            let c = chars[x];
            let x = x as i64;
            let y = y as i64;

            if c != ' ' {
                map.min_x.entry(y).or_insert(x);
                map.max_x.insert(y, x);
                map.min_y.entry(x).or_insert(y);
                map.max_y.insert(x, y);
            }

            if c == '#' {
                map.map.insert((x, y), Tile::Wall);
            } else if c == '.' {
                map.map.insert((x, y), Tile::Free);
            }
        }

        y += 1;
    }

    map.init_face_cache();

    println!(
        "Part1: {:?}",
        solve(&map, &moves, |x, dir| map.walk(x, dir))
    );
    println!(
        "Part2: {:?}",
        solve(&map, &moves, |x, dir| map.walk_cube(x, dir))
    );
}

fn solve<F: Fn(Coord, Coord) -> (Coord, Coord)>(map: &Map, moves: &[Move], walk_fn: F) -> i64 {
    let mut x = map.min_x[&0];
    let mut y = 0;
    let mut dir = (1, 0);

    for m in moves {
        match m {
            Move::Right => dir = rotate_right(dir),
            Move::Left => dir = rotate_left(dir),
            Move::Forward(n) => {
                for _ in 0..*n {
                    let ((new_x, new_y), new_dir) = walk_fn((x, y), dir);

                    match map.map[&(new_x, new_y)] {
                        Tile::Free => {
                            x = new_x;
                            y = new_y;
                            dir = new_dir;
                        }
                        Tile::Wall => {
                            break;
                        }
                    }
                }
            }
        }
    }

    1000 * (y + 1) + 4 * (x + 1) + score(dir)
}

fn rotate_right((dx, dy): (i64, i64)) -> (i64, i64) {
    (-dy, dx)
}

fn rotate_left((dx, dy): (i64, i64)) -> (i64, i64) {
    (dy, -dx)
}

fn score(dir: (i64, i64)) -> i64 {
    match dir {
        (1, 0) => 0,
        (0, 1) => 1,
        (-1, 0) => 2,
        (0, -1) => 3,
        _ => panic!("Invalid direction"),
    }
}
