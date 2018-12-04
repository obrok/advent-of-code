data = File.read!("input1.txt") |> String.split()

for s1 <- data do
  for s2 <- data do
    c1 = String.codepoints(s1)
    c2 = String.codepoints(s2)

    Enum.zip(c1, c2)
    |> Enum.count(fn {a, b} -> a != b end)
    |> case do
      1 -> IO.inspect({s1, s2})
      _ -> :ok
    end
  end
end
