use sscanf::{sscanf, FromScanf};
use std::collections::HashSet;
use std::io::stdin;

#[derive(Debug, Clone, FromScanf)]
enum Move {
    #[sscanf("L {}")]
    Left(usize),
    #[sscanf("R {}")]
    Right(usize),
    #[sscanf("U {}")]
    Up(usize),
    #[sscanf("D {}")]
    Down(usize),
}

impl Move {
    fn is_empty(&self) -> bool {
        match self {
            Move::Left(0) | Move::Right(0) | Move::Up(0) | Move::Down(0) => true,
            _ => false,
        }
    }

    fn dec(&mut self) {
        match self {
            Move::Left(x) => *x -= 1,
            Move::Right(x) => *x -= 1,
            Move::Up(x) => *x -= 1,
            Move::Down(x) => *x -= 1,
        }
    }
}

type Pos = (i32, i32);

fn main() {
    let mut moves = vec![];
    for line in stdin().lines() {
        let line = line.unwrap();
        let m = sscanf!(line, "{Move}").unwrap();
        moves.push(m);
    }

    println!("Part1: {}", simulate(moves.clone(), 2));
    println!("Part2: {}", simulate(moves.clone(), 10));
}

fn simulate(mut moves: Vec<Move>, knots: usize) -> usize {
    let mut knots = vec![(0, 0); knots];
    let mut visited = HashSet::new();

    while !moves.is_empty() {
        if moves[0].is_empty() {
            moves.remove(0);
        } else {
            apply_move(&mut knots[0], &moves[0]);
            for i in 0..(knots.len() - 1) {
                follow_tail(&knots[i].clone(), &mut knots[i + 1])
            }

            moves[0].dec();
            visited.insert(knots[knots.len() - 1].clone());
        }
    }

    visited.len()
}

fn apply_move(head: &mut Pos, m: &Move) {
    match m {
        Move::Up(_) => head.1 += 1,
        Move::Down(_) => head.1 -= 1,
        Move::Left(_) => head.0 -= 1,
        Move::Right(_) => head.0 += 1,
    }
}

fn follow_tail(head: &Pos, tail: &mut Pos) {
    if head.0.abs_diff(tail.0) == 2 && head.1.abs_diff(tail.1) == 2 {
        tail.0 = (tail.0 + head.0) / 2;
        tail.1 = (tail.1 + head.1) / 2;
    }

    if head.0.abs_diff(tail.0) == 2 && head.1.abs_diff(tail.1) == 1 {
        tail.1 = head.1;
    }
    if head.1.abs_diff(tail.1) == 2 && head.0.abs_diff(tail.0) == 1 {
        tail.0 = head.0;
    }

    if head.0.abs_diff(tail.0) == 2 {
        tail.0 = (tail.0 + head.0) / 2;
    } else if head.1.abs_diff(tail.1) == 2 {
        tail.1 = (tail.1 + head.1) / 2;
    }
}
