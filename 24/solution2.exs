defmodule Immune do
  def parse(input) do
    lines = String.split(input, "\n", trim: true)
    immune = lines |> Enum.drop(1) |> Enum.take_while(&(&1 != "Infection:"))
    infection = lines |> Enum.drop_while(&(&1 != "Infection:")) |> Enum.drop(1)

    %{
      immune:
        immune
        |> Enum.with_index()
        |> Enum.map(&parse_group(&1, :immune))
        |> Enum.map(&{&1.id, &1})
        |> Enum.into(%{}),
      infection:
        infection
        |> Enum.with_index()
        |> Enum.map(&parse_group(&1, :infection))
        |> Enum.map(&{&1.id, &1})
        |> Enum.into(%{})
    }
  end

  defp parse_group({line, index}, army) do
    [_, size, hp, traits, attack, attack_type, initiative] =
      Regex.run(
        ~r/(\d+) units each with (\d+) hit points (\(.*?\) )?with an attack that does (\d+) (\w+) damage at initiative (\d+)/,
        line
      )

    %{
      id: {army, index + 1},
      size: String.to_integer(size),
      hp: String.to_integer(hp),
      weak: parse_weak(traits),
      immune: parse_immune(traits),
      attack: String.to_integer(attack),
      attack_type: String.to_atom(attack_type),
      initiative: String.to_integer(initiative)
    }
  end

  defp parse_weak(traits) do
    case Regex.run(~r/weak to (\w+,? ?)+/, traits) do
      nil ->
        []

      ["weak to " <> weaknesses | _] ->
        weaknesses |> String.split(", ") |> Enum.map(&String.to_atom/1)
    end
  end

  defp parse_immune(traits) do
    case Regex.run(~r/immune to (\w+,? ?)+/, traits) do
      nil ->
        []

      ["immune to " <> immunities | _] ->
        immunities |> String.split(", ") |> Enum.map(&String.to_atom/1)
    end
  end

  def step(armies) do
    immune_targets = target(Map.values(armies.immune), Map.values(armies.infection))
    infection_targets = target(Map.values(armies.infection), Map.values(armies.immune))

    targets = Map.merge(immune_targets, infection_targets)

    (Map.values(armies.immune) ++ Map.values(armies.infection))
    |> Enum.sort_by(&(-&1.initiative))
    |> Enum.map(& &1.id)
    |> Enum.reduce(armies, fn id, armies ->
      target = targets[id]

      cond do
        is_nil(target) ->
          armies

        armies.immune[id] ->
          update_in(armies, [:infection, target], &attack(&1, armies.immune[id]))

        armies.infection[id] ->
          update_in(armies, [:immune, target], &attack(&1, armies.infection[id]))
      end
    end)
    |> update_in([:infection], &remove_dead/1)
    |> update_in([:immune], &remove_dead/1)
  end

  defp remove_dead(army) do
    army
    |> Enum.reject(fn {_, v} -> v.size <= 0 end)
    |> Enum.into(%{})
  end

  defp attack(group, from) do
    deaths = min(group.size, div(damage(from, group), group.hp))
    put_in(group, [:size], group.size - deaths)
  end

  defp target(targeters, possible_targets) do
    possible_targets = MapSet.new(possible_targets)

    targeters
    |> Enum.sort_by(&{-power(&1), -&1.initiative})
    |> Enum.reduce({%{}, possible_targets}, fn targeter, {targets, possible_targets} ->
      possible_targets
      |> Enum.reject(&(damage(targeter, &1) == 0))
      |> Enum.max_by(&{damage(targeter, &1), power(&1), &1.initiative}, fn -> nil end)
      |> case do
        nil ->
          {targets, possible_targets}

        target ->
          {Map.put(targets, targeter.id, target.id), MapSet.delete(possible_targets, target)}
      end
    end)
    |> elem(0)
  end

  defp damage(from, to) do
    cond do
      from.attack_type in to.immune -> 0
      from.attack_type in to.weak -> 2 * power(from)
      true -> power(from)
    end
  end

  defp power(group), do: group.size * group.attack

  def winning_side(armies) do
    cond do
      size(armies.immune) == 0 -> armies.infection
      size(armies.infection) == 0 -> armies.immune
      true -> nil
    end
  end

  def size(army), do: army |> Map.values() |> Enum.map(& &1.size) |> Enum.sum()

  def boost(armies, boost) do
    update_in(armies, [:immune], fn immune ->
      immune
      |> Enum.map(fn {k, v} -> {k, %{v | attack: v.attack + boost}} end)
      |> Enum.into(%{})
    end)
  end
end

armies = File.read!("input.txt") |> Immune.parse()

1
|> Stream.iterate(&(&1 + 1))
|> Stream.map(fn boost ->
  [prev, _] =
    Immune.boost(armies, boost)
    |> Stream.iterate(&Immune.step/1)
    |> Stream.chunk_every(2, 1)
    |> Enum.find(fn [prev, next] ->
      not is_nil(Immune.winning_side(prev)) or prev == next
    end)

  if Immune.winning_side(prev) do
    Immune.size(prev.immune)
  else
    nil
  end
end)
|> Stream.filter(& &1)
|> Enum.find(&(&1 > 0))
|> IO.inspect()
