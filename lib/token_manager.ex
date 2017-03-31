defmodule TokenManager do

    # Utility.generate_time_limited_token(10,240)

    def generate_time_limited_token(note, n_chars, hours_to_expiration) do
      token_record = Utility.generate_time_limited_token(n_chars,hours_to_expiration)
      tokens = (note.tokens || []) ++ [token_record]
      changeset = Note.changeset(note, %{tokens: tokens})
      Repo.update(changeset)
      token_record
    end

    def match_token(given_token, token_record) do
      token_record["token"] == given_token
    end

    def match_token_array(given_token, note) do
      Enum.reduce(note.tokens, false, fn(token_record, acc) -> match_token(given_token, token_record) or acc end)
    end

end