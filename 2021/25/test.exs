defmodule People.Alice do
end

defmodule People.Bob do
  alias People.Alice

  @friend Alice

  def friend do
    @friend
  end
end

IO.inspect(People.Bob.friend())
