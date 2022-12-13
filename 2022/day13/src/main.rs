use nom::bytes::complete::tag;
use nom::character::complete::u32 as parse_u32;
use nom::multi::separated_list0;
use nom::sequence::delimited;
use nom::IResult;
use std::cmp::Ordering;
use std::io::stdin;

#[derive(Debug, Clone)]
enum Packet {
    List(Vec<Self>),
    Number(u32),
}

impl Eq for Packet {}

impl PartialEq for Packet {
    fn eq(&self, other: &Self) -> bool {
        self.cmp(other) == Ordering::Equal
    }
}

impl Ord for Packet {
    fn cmp(&self, b: &Packet) -> Ordering {
        match (self, b) {
            (&Packet::Number(a), &Packet::Number(b)) => a.cmp(&b),
            (&Packet::List(ref a), &Packet::List(ref b)) => {
                for i in 0..a.len() {
                    if i >= b.len() {
                        return Ordering::Greater;
                    }

                    if a[i].cmp(&b[i]) != Ordering::Equal {
                        return a[i].cmp(&b[i]);
                    }
                }

                return a.len().cmp(&b.len());
            }
            (&Packet::Number(x), _) => Packet::List(vec![Packet::Number(x)]).cmp(b),
            (_, &Packet::Number(x)) => self.cmp(&Packet::List(vec![Packet::Number(x)])),
        }
    }
}

impl PartialOrd for Packet {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

fn packet(line: &str) -> IResult<&str, Packet> {
    if line.starts_with("[") {
        let (input, packets) =
            delimited(tag("["), separated_list0(tag(","), packet), tag("]"))(line)?;
        Ok((input, Packet::List(packets)))
    } else {
        let (input, number) = parse_u32(line)?;
        Ok((input, Packet::Number(number)))
    }
}

fn main() {
    let mut input = vec![];

    for line in stdin().lines() {
        let line = line.unwrap();
        if line != "" {
            let (_, p) = packet(&line).unwrap();
            input.push(p);
        }
    }

    let mut total = 0;
    let mut index = 1;
    for chunk in input[..].chunks(2) {
        if chunk[0].cmp(&chunk[1]) != Ordering::Greater {
            total += index;
        }
        index += 1;
    }

    println!("Part1: {}", total);
    println!("Part2: {}", part2(input));
}

fn part2(mut input: Vec<Packet>) -> usize {
    let divider1 = packet("[[2]]").unwrap().1;
    let divider2 = packet("[[6]]").unwrap().1;
    input.push(divider1.clone());
    input.push(divider2.clone());

    input.sort();
    let i1 = input.iter().position(|x| x == &divider1).unwrap() + 1;
    let i2 = input.iter().position(|x| x == &divider2).unwrap() + 1;
    i1 * i2
}
