defmodule MU.Server do

  @name MUServer

  @module_doc """
  The call `MU.Server.render("This _is_ a test"}` returns

  {:ok, "<p>\n This <i>is</i> test. \n</p>\n\n"}

  by calling MU.RenderText.transform(text).  That is,
  MU
"""
   use GenServer

    def start_link(opts \\ []) do
      GenServer.start_link(__MODULE__, :ok, opts ++ [name: MUServer])
    end

    def stop do
        GenServer.cast(@name, :stop)
    end

    def render(message) do
      GenServer.call(@name, {:render, message})
    end

    def get_stats do
      GenServer.call(@name, :get_stats)
    end

    def reset_stats do
      GenServer.cast(@name, :reset_stats)
    end


 # SERVER

   def init(:ok) do
       {:ok, %{requests: 0, characters: 0, processing_time: 0.0, rate: 0.0}}
     end


    def handle_call({:render, message}, _from, stats) do
      start_time = Timex.now
      rendered_text = MU.RenderText.transform(message.text, message.options)
      finish_time = Timex.now

      elapsed_time = Timex.diff( finish_time, start_time, :microseconds)
      IO.puts("elapsed_time = #{elapsed_time}")
      total_elapsed_time = stats.processing_time + elapsed_time
      characters = String.length(rendered_text)
      total_characters = stats.characters + characters
      rate = 1000*total_elapsed_time/total_characters

      new_stats = %{ requests: stats.requests + 1,
        characters: total_characters,
        processing_time: total_elapsed_time,
        rate: rate}
      {:reply, {:ok, rendered_text}, new_stats}
    end

    def handle_call(:get_stats, _from, stats) do
       {:reply, stats, stats}
    end

    def handle_cast(:reset_stats, _stats) do
      {:noreply, %{}}
    end

    def handle_cast(:stop, stats) do
      {:stop, :normal, stats}
    end

    def handle_info(msg, stats) do
      IO.puts "received #{inspect msg}"
      {:noreply, stats}
    end


end