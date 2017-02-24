# http://stackoverflow.com/questions/31523699/setting-properties-in-parent-view-template-in-phoenix

defmodule LookupPhoenix.Plug.Site do

  def init(default), do: default

  def call(conn, opts) do
    assign conn, :site,  Keyword.get(opts, :site)
  end

end