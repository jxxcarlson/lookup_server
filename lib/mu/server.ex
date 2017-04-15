defmodule MU.Server do

  @module_doc """
  The call `MU.Server.render("This _is_ a test"}` returns

  {:ok, "<p>\n This <i>is</i> test. \n</p>\n\n"}

  by calling MU.RenderText.transform(text).  That is,
  MU
"""
   use GenServer

    def start_link do
      GenServer.start_link(__MODULE__, [], name: :mu_server)
    end


    def render(message) do
      GenServer.call(:mu_server, {:render, message})
    end


 # SERVER

   def handle_call({:render, message}, _from, _messages) do
      rendered_text = MU.RenderText.transform(message)
      {:reply, {:ok, rendered_text}, []}
   end

end