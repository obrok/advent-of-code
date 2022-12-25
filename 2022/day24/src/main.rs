use std::collections::BinaryHeap;
use std::collections::HashSet;

fn main() {
    let lines = std::io::stdin()
        .lines()
        .map(|l| l.unwrap().chars().collect::<Vec<_>>())
        .collect::<Vec<_>>();
    let x_size = lines[0].len() - 2;
    let y_size = lines.len() - 2;
    let source = (lines[0].iter().position(|&c| c == '.').unwrap(), 0);
    let sink = (
        lines[lines.len() - 1]
            .iter()
            .position(|&c| c == '.')
            .unwrap(),
        lines.len() - 1,
    );

    let mut by_x = vec![vec![]; lines[0].len()];
    let mut by_y = vec![vec![]; lines.len()];

    for y in 0..lines.len() {
        for x in 0..lines[0].len() {
            if lines[y][x] != '.' && lines[y][x] != '#' {
                let b = Blizzard {
                    x,
                    y,
                    dir: to_dir(lines[y][x]),
                };

                if b.dir == Direction::Up || b.dir == Direction::Down {
                    by_x[x].push(b);
                } else {
                    by_y[y].push(b);
                }
            }
        }
    }

    println!(
        "Part1: {:?}",
        navigate(source, &by_x, &by_y, x_size, y_size, vec![sink])
    );

    println!(
        "Part2: {:?}",
        navigate(
            source,
            &by_x,
            &by_y,
            x_size,
            y_size,
            vec![sink, source, sink]
        )
    );
}

fn navigate(
    source: Coord,
    by_x: &Vec<Vec<Blizzard>>,
    by_y: &Vec<Vec<Blizzard>>,
    x_size: usize,
    y_size: usize,
    targets: Vec<Coord>,
) -> usize {
    let mut queue = BinaryHeap::new();
    let mut visited = HashSet::new();
    queue.push(State {
        x: source.0,
        y: source.1,
        time: 0,
        min_time: calc_min_time(source, &targets, 0),
        target: 0,
    });

    while let Some(mut state) = queue.pop() {
        if state.x == targets[state.target].0 && state.y == targets[state.target].1 {
            state.target += 1;
        }

        if state.target == targets.len() {
            return state.time;
        }

        let next_time = state.time + 1;
        for dir in [(1, 0), (-1, 0), (0, 1), (0, -1)] {
            let x = (state.x as isize + dir.0) as usize;
            let y = (state.y as isize + dir.1) as usize;

            if (x > 0
                && y > 0
                && x < by_x.len() - 1
                && y < by_y.len() - 1
                && !visited.contains(&(x, y, next_time)))
                || (x, y) == targets[state.target]
            {
                visited.insert((x, y, next_time));
                let min_time = calc_min_time((x, y), &targets, state.target);

                if is_free(x, y, next_time, &by_x, &by_y, x_size, y_size) {
                    queue.push(State {
                        x,
                        y,
                        time: next_time,
                        min_time,
                        target: state.target,
                    });
                }
            }

            if is_free(state.x, state.y, next_time, &by_x, &by_y, x_size, y_size)
                && !visited.contains(&(state.x, state.y, next_time))
            {
                visited.insert((state.x, state.y, next_time));
                queue.push(State {
                    x: state.x,
                    y: state.y,
                    time: next_time,
                    min_time: state.min_time,
                    target: state.target,
                });
            }
        }
    }

    panic!("Path not found");
}

fn calc_min_time(from: Coord, targets: &Vec<Coord>, target: usize) -> usize {
    let mut prev = from;
    let mut total = 0;
    for i in target..targets.len() {
        let next = targets[i];
        total += next.0.abs_diff(prev.0) + next.1.abs_diff(prev.1);
        prev = next;
    }

    total
}

fn is_free(
    x: usize,
    y: usize,
    time: usize,
    by_x: &Vec<Vec<Blizzard>>,
    by_y: &Vec<Vec<Blizzard>>,
    x_size: usize,
    y_size: usize,
) -> bool {
    for b in by_x[x].iter() {
        if b.dir == Direction::Down && (b.y - 1 + time) % y_size + 1 == y {
            return false;
        }
        if b.dir == Direction::Up && (b.y - 1 + y_size - time % y_size) % y_size + 1 == y {
            return false;
        }
    }

    for b in by_y[y].iter() {
        if b.dir == Direction::Right && (b.x - 1 + time) % x_size + 1 == x {
            return false;
        }
        if b.dir == Direction::Left && (b.x - 1 + x_size - time % x_size) % x_size + 1 == x {
            return false;
        }
    }

    return true;
}

type Coord = (usize, usize);

#[derive(Debug, Eq, PartialEq)]
struct State {
    x: usize,
    y: usize,
    time: usize,
    min_time: usize,
    target: usize,
}

impl PartialOrd for State {
    fn partial_cmp(&self, other: &Self) -> Option<std::cmp::Ordering> {
        Some(self.cmp(other))
    }
}

impl Ord for State {
    fn cmp(&self, other: &Self) -> std::cmp::Ordering {
        (other.min_time + other.time).cmp(&(self.min_time + self.time))
    }
}

#[derive(Debug, Clone, Copy)]

struct Blizzard {
    x: usize,
    y: usize,
    dir: Direction,
}

#[derive(Debug, Clone, Copy, Eq, PartialEq)]
enum Direction {
    Up,
    Down,
    Left,
    Right,
}

fn to_dir(c: char) -> Direction {
    match c {
        '<' => Direction::Left,
        '>' => Direction::Right,
        '^' => Direction::Up,
        'v' => Direction::Down,
        _ => panic!("Unknown direction"),
    }
}
