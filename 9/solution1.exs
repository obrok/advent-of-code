defmodule Game do
  def new(players, last_marble) do
    %{
      players: players,
      current_player: 0,
      scores: %{},
      last_marble: last_marble,
      next_marble: 1,
      current_marble_index: 0,
      marbles: [0],
      length_marbles: 1
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
    index = counter_clockwise(game.length_marbles, game.current_marble_index, 7)
    score = Enum.at(game.marbles, index) + game.next_marble

    game
    |> update_in([:scores], &Map.update(&1, game.current_player, score, fn x -> x + score end))
    |> update_in([:marbles], &List.delete_at(&1, index))
    |> update_in([:length_marbles], &(&1 - 1))
    |> put_in([:current_marble_index], index)
  end

  def add_marble(game) do
    index = clockwise(game.length_marbles, game.current_marble_index, 2)

    game
    |> update_in([:marbles], &List.insert_at(&1, index, game.next_marble))
    |> update_in([:length_marbles], &(&1 + 1))
    |> put_in([:current_marble_index], index)
  end

  def clockwise([_], 0, _), do: 1
  def clockwise(marbles, from, number), do: rem(from + number, marbles)

  def counter_clockwise(marbles, from, number) do
    index = from - number
    if index < 0, do: marbles + index, else: index
  end
end

players = 430
last_marble = 71588

Game.new(players, last_marble)
|> Game.play()
|> get_in([:scores])
|> Map.values()
|> Enum.max()
|> IO.inspect()
