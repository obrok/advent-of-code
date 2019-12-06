defmodule Cart do
  def new(loc, char) do
    %{loc: loc, dir: char, turn: 0}
  end

  def tick(map, cart) do
    %{cart | loc: new_loc(cart)}
    |> turn(map)
  end

  defp new_loc(%{dir: dir, loc: {x, y}}) do
    case dir do
      "^" -> {x, y - 1}
      "<" -> {x - 1, y}
      ">" -> {x + 1, y}
      "v" -> {x, y + 1}
    end
  end

  defp turn(cart, map) do
    {dir, turn} =
      case {map[cart.loc], cart.dir, cart.turn} do
        {"\\", "^", t} -> {"<", t}
        {"\\", "<", t} -> {"^", t}
        {"\\", ">", t} -> {"v", t}
        {"\\", "v", t} -> {">", t}
        {"/", "^", t} -> {">", t}
        {"/", "<", t} -> {"v", t}
        {"/", ">", t} -> {"^", t}
        {"/", "v", t} -> {"<", t}
        {"+", "<", 0} -> {"v", 1}
        {"+", "^", 0} -> {"<", 1}
        {"+", "v", 0} -> {">", 1}
        {"+", ">", 0} -> {"^", 1}
        {"+", dir, 1} -> {dir, 2}
        {"+", "<", 2} -> {"^", 0}
        {"+", "^", 2} -> {">", 0}
        {"+", "v", 2} -> {"<", 0}
        {"+", ">", 2} -> {"v", 0}
        {nil, _, _} -> raise "Shouldn't happen"
        {_, dir, turn} -> {dir, turn}
      end

    %{cart | dir: dir, turn: turn}
  end
end

defmodule CartMap do
  def parse(lines) do
    for {line, y} <- Enum.with_index(lines), {char, x} <- Enum.with_index(line) do
      {char, {x, y}}
    end
    |> Enum.reduce({%{}, [], []}, fn {char, loc}, {map, carts, collisions} ->
      case char do
        " " -> {map, carts, collisions}
        s when s in ["<", ">"] -> {Map.put(map, loc, "-"), [Cart.new(loc, s) | carts], collisions}
        s when s in ["^", "v"] -> {Map.put(map, loc, "|"), [Cart.new(loc, s) | carts], collisions}
        s -> {Map.put(map, loc, s), carts, collisions}
      end
    end)
  end

  def tick({map, carts, _}) do
    to_move = carts |> Enum.map(& &1.loc) |> Enum.sort_by(fn {x, y} -> {y, x} end)
    carts = carts |> Enum.map(&{&1.loc, &1}) |> Enum.into(%{})

    {carts, collisions} =
      Enum.reduce(to_move, {carts, []}, fn loc, {carts, collisions} ->
        cart = Cart.tick(map, carts[loc])
        carts = Map.delete(carts, loc)

        if carts[cart.loc] do
          {carts, [cart.loc | collisions]}
        else
          {Map.put(carts, cart.loc, cart), collisions}
        end
      end)

    {map, Map.values(carts), collisions}
  end

  def collisions({_, _, collisions}) do
    collisions
  end
end

File.read!("input.txt")
|> String.split("\n", trim: true)
|> Enum.map(&String.graphemes/1)
|> CartMap.parse()
|> Stream.iterate(&CartMap.tick/1)
|> Enum.find(&(length(CartMap.collisions(&1)) > 0))
|> CartMap.collisions()
|> IO.inspect()
