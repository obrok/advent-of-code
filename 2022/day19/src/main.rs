use sscanf::sscanf;
use std::cmp::max;

type Resources = [usize; 4];

#[derive(Debug, Clone)]
struct Blueprint {
    id: usize,
    robots: [Robot; 4],
}

impl Blueprint {
    fn max_ore_cost(&self) -> usize {
        self.robots.iter().map(|r| r.cost[0]).max().unwrap()
    }
}

#[derive(Debug, Clone)]
struct Robot {
    cost: Resources,
}

impl Robot {
    fn time_needed(&self, production: Resources, resources: Resources) -> Option<usize> {
        let mut worst = 0;
        for i in 0..4 {
            if self.cost[i] == 0 {
                continue;
            } else if production[i] == 0 {
                return None;
            } else {
                let needed = self.cost[i].saturating_sub(resources[i]);
                let t = if needed % production[i] == 0 {
                    needed / production[i]
                } else {
                    needed / production[i] + 1
                };

                worst = max(worst, t)
            }
        }

        Some(worst + 1)
    }
}

fn main() {
    let blueprints = std::io::stdin()
        .lines()
        .map(|line| {
            let line = line.unwrap();
            let parts = line.split(". ").collect::<Vec<_>>();
            let (id, ore_cost) = sscanf!(
                parts[0],
                "Blueprint {usize}: Each ore robot costs {usize} ore"
            )
            .unwrap();
            let clay_cost = sscanf!(parts[1], "Each clay robot costs {usize} ore").unwrap();
            let (obsidian1, obsidian2) = sscanf!(
                parts[2],
                "Each obsidian robot costs {usize} ore and {usize} clay"
            )
            .unwrap();
            let (geode1, geode2) = sscanf!(
                parts[3],
                "Each geode robot costs {usize} ore and {usize} obsidian."
            )
            .unwrap();

            Blueprint {
                id,
                robots: [
                    Robot {
                        cost: [ore_cost, 0, 0, 0],
                    },
                    Robot {
                        cost: [clay_cost, 0, 0, 0],
                    },
                    Robot {
                        cost: [obsidian1, obsidian2, 0, 0],
                    },
                    Robot {
                        cost: [geode1, 0, geode2, 0],
                    },
                ],
            }
        })
        .collect::<Vec<_>>();

    let total = blueprints
        .clone()
        .into_iter()
        .map(|blueprint| blueprint.id * sim(&blueprint, 24))
        .sum::<usize>();
    println!("Part1: {}", total);

    let part2 = sim(&blueprints[0], 32) * sim(&blueprints[1], 32) * sim(&blueprints[2], 32);
    println!("Part2: {}", part2);
}

fn sim(blueprint: &Blueprint, initial_time: usize) -> usize {
    let production = [1, 0, 0, 0];
    let resources = [0; 4];
    let mut queue = vec![(initial_time, production, resources)];
    let mut best = 0;

    while let Some((time, production, resources)) = queue.pop() {
        let best_possible = resources[3] + production[3] * time + time * time / 2;

        for r in 0..4 {
            let robot = &blueprint.robots[r];
            if r == 0 && production[0] == blueprint.max_ore_cost()
                || r == 1 && production[1] == blueprint.robots[2].cost[1]
                || r == 2 && production[2] == blueprint.robots[3].cost[2]
                || best_possible <= best
            {
                continue;
            }

            let time_needed = robot.time_needed(production, resources);

            if let Some(time_needed) = time_needed {
                if time_needed > time {
                    let score = resources[3] + production[3] * time;
                    if score > best {
                        best = score;
                    }
                } else {
                    let mut production = production.clone();
                    let mut resources = resources.clone();
                    let time = time - time_needed;
                    for i in 0..4 {
                        resources[i] += production[i] * time_needed;
                        resources[i] = resources[i].checked_sub(robot.cost[i]).unwrap();
                    }
                    production[r] += 1;

                    queue.push((time, production, resources));
                }
            }
        }
    }

    best
}
