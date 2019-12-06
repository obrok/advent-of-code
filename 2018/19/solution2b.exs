number = 10_551_330

1..number
|> Enum.filter(&(rem(number, &1) == 0))
|> Enum.sum()
|> IO.inspect()
