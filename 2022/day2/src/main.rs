use std::io::stdin;

#[derive(PartialEq, Eq, Clone, Copy)]
enum Shape {
    Rock,
    Paper,
    Scissors,
}

#[derive(PartialEq, Eq, Clone, Copy)]
enum MatchScore {
    Win,
    Draw,
    Lose,
}

fn main() {
    let mut result1 = 0;
    let mut result2 = 0;

    for line in stdin().lines() {
        let line = line.unwrap();
        let parts = line.split(" ").collect::<Vec<_>>();

        let shape = match parts[0] {
            "A" => Shape::Rock,
            "B" => Shape::Paper,
            "C" => Shape::Scissors,
            _ => panic!(),
        };

        let shape2 = match parts[1] {
            "X" => Shape::Rock,
            "Y" => Shape::Paper,
            "Z" => Shape::Scissors,
            _ => panic!(),
        };

        let outcome = match parts[1] {
            "X" => MatchScore::Lose,
            "Y" => MatchScore::Draw,
            "Z" => MatchScore::Win,
            _ => panic!(),
        };

        result1 += match_score(match_result(shape2, shape)) + shape_score(shape2);
        result2 += match_score(outcome) + shape_score(needed_shape(shape, outcome));
    }

    println!("Result1: {}", result1);
    println!("Result2: {}", result2)
}

fn shape_score(shape: Shape) -> u32 {
    match shape {
        Shape::Rock => 1,
        Shape::Paper => 2,
        Shape::Scissors => 3,
    }
}

fn match_score(score: MatchScore) -> u32 {
    match score {
        MatchScore::Win => 6,
        MatchScore::Draw => 3,
        MatchScore::Lose => 0,
    }
}

fn match_result(shape1: Shape, shape2: Shape) -> MatchScore {
    match (shape1, shape2) {
        (x, y) if x == y => MatchScore::Draw,
        (Shape::Rock, Shape::Scissors) => MatchScore::Win,
        (Shape::Paper, Shape::Rock) => MatchScore::Win,
        (Shape::Scissors, Shape::Paper) => MatchScore::Win,
        _ => MatchScore::Lose,
    }
}

fn needed_shape(shape: Shape, score: MatchScore) -> Shape {
    match (shape, score) {
        (_, MatchScore::Draw) => shape,
        (Shape::Rock, MatchScore::Win) => Shape::Paper,
        (Shape::Rock, MatchScore::Lose) => Shape::Scissors,
        (Shape::Paper, MatchScore::Win) => Shape::Scissors,
        (Shape::Paper, MatchScore::Lose) => Shape::Rock,
        (Shape::Scissors, MatchScore::Win) => Shape::Rock,
        (Shape::Scissors, MatchScore::Lose) => Shape::Paper,
    }
}
