defmodule Marbles do
  def new(), do: {[0], []}

  def clockwise(marbles, 0), do: marbles

  def clockwise({[marble | rest], marbles}, number),
    do: clockwise({rest, [marble | marbles]}, number - 1)

  def clockwise({[], marbles}, number), do: clockwise({Enum.reverse(marbles), []}, number)

  def put({left, right}, value), do: {[value | left], right}

  def counter_clockwise(marbles, 0), do: marbles

  def counter_clockwise({marbles, [marble | rest]}, number),
    do: counter_clockwise({[marble | marbles], rest}, number - 1)

  def counter_clockwise({marbles, []}, number),
    do: counter_clockwise({[], Enum.reverse(marbles)}, number)

  def pop({[marble | rest], marbles}), do: {{rest, marbles}, marble}
  def pop({[], marbles}), do: pop({Enum.reverse(marbles), []})
end

defmodule Game do
  def new(players, last_marble) do
    %{
      players: players,
      current_player: 0,
      scores: %{},
      last_marble: last_marble,
      next_marble: 1,
      marbles: Marbles.new()
    }
  end

  def play(game) do
    cond do
      game.next_marble > game.last_marble -> game
      rem(game.next_marble, 23) == 0 -> game |> score_marble() |> next_player() |> play()
      true -> game |> add_marble() |> next_player() |> play()
    end
  end

  def next_player(game) do
    game
    |> update_in([:current_player], &rem(&1 + 1, game.players))
    |> update_in([:next_marble], &(&1 + 1))
  end

  def score_marble(game) do
    {marbles, value} = game.marbles |> Marbles.counter_clockwise(7) |> Marbles.pop()
    score = game.next_marble + value

    game
    |> update_in([:scores], &Map.update(&1, game.current_player, score, fn x -> x + score end))
    |> put_in([:marbles], marbles)
  end

  def add_marble(game) do
    game
    |> update_in([:marbles], &Marbles.clockwise(&1, 2))
    |> update_in([:marbles], &Marbles.put(&1, game.next_marble))
  end
end

players = 430
last_marble = 7_158_800

Game.new(players, last_marble)
|> Game.play()
|> get_in([:scores])
|> Map.values()
|> Enum.max()
|> IO.inspect()
