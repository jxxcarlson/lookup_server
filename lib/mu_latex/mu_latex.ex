defmodule MU.Render2Latex do
  alias LookupPhoenix.Repo
  alias LookupPhoenix.Note
  alias LookupPhoenix.Utility

    # mode = plain | markup | latex | collate | toc

    def transform(text, options \\ %{mode: "show", process: "markup"}) do
      text
    end

end