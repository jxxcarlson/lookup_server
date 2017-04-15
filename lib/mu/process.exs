defmodule MU.Spawn do

require MU.RenderText
# import MU.RenderText

  def render do
    receive do
      {sender, msg} ->
        send sender, { :ok, MU.RenderText.transform(msg) }
        render()
    end
  end

end

# Client
pid = spawn(MU.Spawn, :render, [])
send pid, {self(), "This _is_ a test. (1)"}

receive do
  { :ok, message } ->
  IO.puts message
end

send pid, {self(), "This _is_ a test. (1)"}
receive do
  {:ok, message} ->
    IO.puts message
  after 500 ->
    IO.puts "The renderer has gone away"
end
