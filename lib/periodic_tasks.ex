# http://stackoverflow.com/questions/32085258/how-to-run-some-code-every-few-hours-in-phoenix-framework

defmodule LookupPhoenix.Periodically do
  use GenServer
  alias LookupPhoenix.Repo
  alias LookupPhoenix.User

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work() # Schedule work to be performed at some point
    {:ok, state}
  end

  def handle_info(:work, state) do
    User |> Repo.all |> Enum.map(fn(user) -> User.update_tags(user) end)
    schedule_work() # Reschedule once more
    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, 1 * 60 * 60 * 1000) # In 1 hour
  end
end