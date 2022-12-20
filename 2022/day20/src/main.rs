fn main() {
    let numbers = std::io::stdin()
        .lines()
        .map(|line| line.unwrap().parse::<isize>().unwrap())
        .collect::<Vec<_>>();

    println!("Part1: {:?}", decrypt(&numbers, 1, 1));
    println!("Part2: {:?}", decrypt(&numbers, 811589153, 10));
}

fn decrypt(numbers: &Vec<isize>, key: isize, rounds: usize) -> isize {
    let mut indices = (0..numbers.len()).collect::<Vec<_>>();

    for _ in 0..rounds {
        for i in 0..numbers.len() {
            let n = numbers[i] * key % (numbers.len() - 1) as isize;
            let mut i = indices.iter().position(|&x| x == i).unwrap();

            let direction = if n >= 0 { 1 } else { -1 };
            for _ in 0..n.abs() {
                let next = shift_index(i, direction, indices.len());
                indices.swap(i, next);
                i = next;
            }
        }
    }

    let zero = indices.iter().position(|&x| numbers[x] == 0).unwrap();
    let index1 = shift_index(zero, 1000, indices.len());
    let index2 = shift_index(zero, 2000, indices.len());
    let index3 = shift_index(zero, 3000, indices.len());

    numbers[indices[index1]] * key + numbers[indices[index2]] * key + numbers[indices[index3]] * key
}

fn shift_index(index: usize, adjustment: isize, length: usize) -> usize {
    let new_index = index as isize + adjustment;

    if new_index < 0 {
        length - ((-new_index) as usize % length)
    } else {
        new_index as usize % length
    }
}
