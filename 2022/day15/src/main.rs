use sscanf::sscanf;
use std::io::stdin;

type Point = (i32, i32);
type Interval = (i32, i32);

fn main() {
    let mut input = vec![];

    for line in stdin().lines() {
        let line = line.unwrap();
        let (x1, y1, x2, y2) = sscanf!(
            line,
            "Sensor at x={i32}, y={i32}: closest beacon is at x={i32}, y={i32}",
        )
        .unwrap();

        input.push(((x1, y1), (x2, y2)));
    }

    println!(
        "Part1 (example): {}",
        impossible(&input, 10).iter().map(size).sum::<i32>()
    );
    println!(
        "Part1: {}",
        impossible(&input, 2000000).iter().map(size).sum::<i32>()
    );
    println!("Part2 (example): {:?}", part2(&input, 0, 20));
    println!("Part2: {:?}", part2(&input, 0, 4000000));
}

fn part2(sensors: &Vec<(Point, Point)>, y_min: i32, y_max: i32) -> Option<u128> {
    for y in y_min..=y_max {
        let imp = impossible(sensors, y);
        if imp.len() == 2 {
            let x = imp.iter().map(|i| i.1).min().unwrap() + 1;
            return Some((x as u128) * 4000000 + (y as u128));
        }
    }

    None
}

fn impossible(sensors: &Vec<(Point, Point)>, target_y: i32) -> Vec<Interval> {
    let mut intervals = vec![];

    for &(sensor, beacon) in sensors {
        let y_dist = (sensor.1 - target_y).abs();
        let d = dist(sensor, beacon);
        if y_dist <= d {
            intervals.push((sensor.0 - (d - y_dist), sensor.0 + (d - y_dist)));
        }
    }

    merge(intervals)
}

fn dist((x1, y1): Point, (x2, y2): Point) -> i32 {
    (x1 - x2).abs() + (y1 - y2).abs()
}

fn merge(mut intervals: Vec<Interval>) -> Vec<Interval> {
    let mut result = vec![];

    while let Some(interval) = intervals.pop() {
        let mut interval = interval;
        let mut i = 0;
        let mut did_merge = false;

        while i < intervals.len() {
            if let Some(merged) = merge_interval(interval, intervals[i]) {
                interval = merged;
                intervals.remove(i);
                did_merge = true;
            } else {
                i += 1;
            }
        }

        if did_merge {
            intervals.push(interval);
        } else {
            result.push(interval);
        }
    }

    result
}

fn merge_interval((x1, x2): Interval, (y1, y2): Interval) -> Option<Interval> {
    if x1 <= y1 && y1 <= x2 {
        Some((x1, x2.max(y2)))
    } else if y1 <= x1 && x1 <= y2 {
        Some((y1, x2.max(y2)))
    } else if y1 == x2 + 1 || x1 == y2 + 1 {
        Some((x1.min(y1), x2.max(y2)))
    } else {
        None
    }
}

fn size(&(x1, x2): &Interval) -> i32 {
    x2 - x1
}
