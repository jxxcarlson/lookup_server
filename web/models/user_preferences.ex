defmodule Preferences do

  use LookupPhoenix.Web, :model

  # embedded_schema is short for:
  #
  #   @primary_key {:id, :binary_id, autogenerate: true}
  #   schema "embedded Item" do


  #
  embedded_schema do
    field :sort_direction, :string
  end
end

