use sscanf::sscanf;
use std::cmp::max;
use std::collections::HashMap;
use std::collections::HashSet;
use std::io::stdin;

#[derive(Debug, Clone, Copy, Eq, PartialEq)]
struct State {
    score: u32,
    time1: u32,
    time2: u32,
    node1: usize,
    node2: usize,
    enabled: u64,
}

impl PartialOrd for State {
    fn partial_cmp(&self, other: &Self) -> Option<std::cmp::Ordering> {
        Some(self.cmp(other))
    }
}

impl Ord for State {
    fn cmp(&self, other: &Self) -> std::cmp::Ordering {
        (self.score, self.time1 + self.time2).cmp(&(other.score, other.time1 + other.time2))
    }
}

fn main() {
    let mut flow_rates = vec![0; 64];
    let mut edges = HashMap::new();
    let mut node_ids = HashMap::from([("AA".to_string(), 0)]);
    let mut next_id = 0;

    stdin().lines().map(|l| l.unwrap()).for_each(|l| {
        let (name, rate, _, _, _, tunnels) = sscanf!(
            l,
            "Valve {String} has flow rate={u32}; tunnel{str:/s?/} lead{str:/s?/} to valve{str:/s?/} {String}"
        )
        .unwrap();

        let id = node_id(&mut node_ids, &mut next_id, name);
        let tunnels = tunnels
            .split(", ")
            .map(|s| (node_id(&mut node_ids, &mut next_id, s.to_string()), 1))
            .collect::<Vec<_>>();

        flow_rates[id] = rate;
        edges.insert(id, tunnels);
    });

    println!("{:?}", edges);
    println!("{:?}", flow_rates);

    let (dist, nodes) = compact(&edges, &flow_rates);

    println!("Part1: {:?}", solve(&flow_rates, &dist, &nodes, 30, 0));
    println!("Part2: {:?}", solve(&flow_rates, &dist, &nodes, 26, 26));
}

fn node_id(node_ids: &mut HashMap<String, usize>, next_id: &mut usize, name: String) -> usize {
    *node_ids.entry(name).or_insert_with(|| {
        let id = *next_id;
        *next_id += 1;
        id
    })
}

fn compact(
    edges: &HashMap<usize, Vec<(usize, u32)>>,
    flow_rates: &Vec<u32>,
) -> (Vec<Vec<u32>>, Vec<usize>) {
    let relevant = (1..64)
        .filter(|x| flow_rates[*x] > 0)
        .collect::<HashSet<_>>();

    let mut dist = vec![vec![0; 64]; 64];
    let mut nodes = vec![0];

    for start in relevant.iter() {
        nodes.push(*start);
        let mut queue = std::collections::VecDeque::new();
        let mut visited = HashSet::new();
        queue.push_back((start, 0));

        while let Some((node, d)) = queue.pop_front() {
            visited.insert(node.clone());
            if node != start && relevant.contains(&node) {
                dist[*start][*node] = d;
            }

            for (next, _) in edges[node].iter() {
                if !visited.contains(next) {
                    queue.push_back((&next, d + 1));
                }
            }
        }
    }

    (dist, nodes)
}

fn solve(
    flow_rates: &Vec<u32>,
    dist: &Vec<Vec<u32>>,
    nodes: &Vec<usize>,
    time1: u32,
    time2: u32,
) -> u32 {
    let mut queue = std::collections::BinaryHeap::new();
    let best_edge = nodes
        .iter()
        .map(|&node| nodes.iter().map(|&other| dist[node][other]).min().unwrap())
        .min()
        .unwrap();
    let mut visited = HashSet::new();
    let mut discarded = 0;

    let mut sorted_flow_rates = flow_rates.clone();
    sorted_flow_rates.sort();
    sorted_flow_rates.reverse();

    queue.push(State {
        score: 0,
        time1,
        time2,
        node1: 0,
        node2: 0,
        enabled: insert(0, 0),
    });

    let mut best = 0;
    while let Some(State {
        score,
        time1,
        time2,
        node1,
        node2,
        enabled,
    }) = queue.pop()
    {
        let greedy =
            score + greedy_score(flow_rates, dist, nodes, node1, node2, time1, time2, enabled);
        let max_s = score + max_score(&flow_rates, &nodes, enabled, best_edge, time1, time2);
        if greedy > best {
            println!(
                "queue: {}, score: ({} <= {} <= {}), time: ({} / {}), enabled: {:?}, discarded: {}",
                queue.len(),
                greedy,
                score,
                max_s,
                time1,
                time2,
                enabled,
                discarded
            );
        } else if queue.len() % 1000 == 0 {
            println!("queue: {}", queue.len());
        }
        best = max(best, greedy);

        let t = (time1, time2, node1, node2, enabled);
        if max_s < best || visited.contains(&t) {
            discarded += 1;
            continue;
        }
        visited.insert(t);

        for &next in nodes.iter() {
            if next != node1 && next != 0 && !contains(enabled, next) {
                let d = dist[node1][next];

                if time1 > d + 1 {
                    let time1 = time1 - d - 1;

                    queue.push(State {
                        score: score + flow_rates[next] * time1,
                        time1,
                        time2,
                        node1: next,
                        node2,
                        enabled: insert(enabled, next),
                    });
                }

                let d = dist[node2][next];
                if time2 > d + 1 {
                    let time2 = time2 - d - 1;

                    queue.push(State {
                        score: score + flow_rates[next] * time2,
                        time1,
                        time2,
                        node1,
                        node2: next,
                        enabled: insert(enabled, next),
                    });
                }
            }
        }
    }

    best
}

fn insert(bitset: u64, node: usize) -> u64 {
    bitset | (1 << node)
}

fn contains(bitset: u64, node: usize) -> bool {
    bitset & (1 << node) != 0
}

fn greedy_score(
    flow_rates: &Vec<u32>,
    edges: &Vec<Vec<u32>>,
    nodes: &Vec<usize>,
    mut node1: usize,
    mut node2: usize,
    mut time1: u32,
    mut time2: u32,
    enabled: u64,
) -> u32 {
    let mut remaining = nodes
        .iter()
        .cloned()
        .filter(|&n| !contains(enabled, n))
        .collect::<Vec<_>>();

    remaining.sort_by_key(|&n| flow_rates[n]);
    remaining.reverse();

    let mut total = 0;
    for &node in remaining.iter() {
        let d = edges[node1][node];
        if d > 0 && time1 > d + 1 {
            insert(enabled, node);
            node1 = node;
            time1 -= d + 1;
            total += flow_rates[node] * time1;
        }
    }

    for &node in remaining.iter() {
        let d = edges[node2][node];
        if !contains(enabled, node) && d > 0 && time2 > d + 1 {
            node2 = node;
            time2 -= d + 1;
            total += flow_rates[node] * time2;
        }
    }

    total
}

fn max_score(
    flow_rates: &Vec<u32>,
    nodes: &Vec<usize>,
    enabled: u64,
    best_edge: u32,
    time1: u32,
    time2: u32,
) -> u32 {
    let mut i = 0;
    let mut total = 0;

    let mut sorted_flow_rates = nodes
        .iter()
        .cloned()
        .filter(|&x| !contains(enabled, x))
        .map(|x| flow_rates[x])
        .collect::<Vec<_>>();
    sorted_flow_rates.sort();
    sorted_flow_rates.reverse();

    let mut time = time1;
    while time > best_edge + 1 && i < sorted_flow_rates.len() {
        time -= best_edge + 1;
        total += sorted_flow_rates[i] * time;
        i += 1;
    }

    let mut time = time2;
    while time > best_edge + 1 && i < sorted_flow_rates.len() {
        time -= best_edge + 1;
        total += sorted_flow_rates[i] * time;
        i += 1;
    }

    total
}
