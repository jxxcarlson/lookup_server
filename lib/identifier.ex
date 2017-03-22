defmodule LookupPhoenix.Identifier do

  use Ecto.Schema
  import Ecto.Query
  alias LookupPhoenix.Utility
  alias LookupPhoenix.Note
  alias LookupPhoenix.Repo


    # If user is "joe"
    # joe.foobar => joe.foobar
    # hoho.foobar => joe.foobar
    # foobar => joe.foobar
    def normalize(user, identifier) do
      if String.contains?(identifier, ".") do
        identifier_parts = String.split(identifier, ".")
        if hd(identifier_parts) == user.username do
        identifier = tl(identifier_parts) |> Enum.join(".")
        end
      end
      "#{user.username}.#{identifier}"
    end

    def find_note(identifier) do
      query = Ecto.Query.from note in Note,
              where: note.identifier == ^identifier
      Repo.one(query)
    end

    defp random_string(length) do
      :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
    end


    # Return unique identifier
    # Example: make("jxx", "foo.bar")
    # returns 'foo.bar.1' if there are no identifiers
    # of the form 'foo.bar.n'.  If 'foo.bar.10' is the
    # identifier matching foo.bar.n with maximal n,
    # the 'foo.bar.11' is returned.
    def make(username, title) do
      identifier = username <> "." <> title
      |> String.downcase
      |> Utility.sanitize_string
      query = Ecto.Query.from note in Note,
        select: note.identifier,
        where: ilike(note.identifier, ^"%#{identifier}%")
      identifiers = Repo.all(query)

      numerical_suffixes = identifiers |> Enum.map(fn(identifier) -> String.split(identifier, ".") |> Utility.last end)
      |> Enum.filter(fn(identifier) -> Regex.match?(~r/^[0-9]+/, identifier) end)
      |> Enum.map(fn(item) -> String.to_integer(item) end)
      |> Enum.sort

      last_id_suffix = numerical_suffixes |> Utility.last

      cond do
        length(identifiers) == 0 -> identifier
        numerical_suffixes == [] -> "#{identifier}.1"
        true -> suffix = last_id_suffix + 1; "#{identifier}.#{suffix}"
      end
    end


end