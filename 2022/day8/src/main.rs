fn main() {
    let mut trees = vec![];
    let mut visible = vec![];
    for line in std::io::stdin().lines() {
        let line = line
            .unwrap()
            .chars()
            .map(|c| c as i32 - '0' as i32)
            .collect::<Vec<_>>();
        visible.push(vec![false; line.len()]);
        trees.push(line);
    }

    for i in 0..trees.len() {
        let mut max = -1;
        for j in 0..trees[0].len() {
            if trees[i][j] > max {
                max = trees[i][j];
                visible[i][j] = true;
            }
        }
        let mut max = -1;
        for j in (0..trees[0].len()).rev() {
            if trees[i][j] > max {
                max = trees[i][j];
                visible[i][j] = true;
            }
        }
    }
    for j in 0..trees[0].len() {
        let mut max = -1;
        for i in 0..trees.len() {
            if trees[i][j] > max {
                max = trees[i][j];
                visible[i][j] = true;
            }
        }
        let mut max = -1;
        for i in (0..trees.len()).rev() {
            if trees[i][j] > max {
                max = trees[i][j];
                visible[i][j] = true;
            }
        }
    }

    let mut total_visible = 0;
    for l in visible {
        for x in l {
            if x {
                total_visible += 1
            }
        }
    }
    println!("Part1: {}", total_visible);

    let mut best = 0;
    for i in 0..trees.len() {
        for j in 0..trees[0].len() {
            let s = score(&trees, i, j);
            if s > best {
                best = s;
            }
        }
    }
    println!("Part2: {}", best);
}

fn score(trees: &Vec<Vec<i32>>, i: usize, j: usize) -> i32 {
    let mut s1 = 0;
    for k in (0..i).rev() {
        s1 += 1;
        if trees[k][j] >= trees[i][j] {
            break;
        }
    }

    let mut s2 = 0;
    for k in (i + 1)..trees.len() {
        s2 += 1;
        if trees[k][j] >= trees[i][j] {
            break;
        }
    }

    let mut s3 = 0;
    for k in (0..j).rev() {
        s3 += 1;
        if trees[i][k] >= trees[i][j] {
            break;
        }
    }

    let mut s4 = 0;
    for k in (j + 1)..trees[0].len() {
        s4 += 1;
        if trees[i][k] >= trees[i][j] {
            break;
        }
    }

    s1 * s2 * s3 * s4
}
