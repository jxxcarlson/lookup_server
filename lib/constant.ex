defmodule LookupPhoenix.Constant do

  def random_note_threshold do
    30
  end

  def tag_frequency_threshold do
    2
  end

  def default_site_id do
    23
  end

  def home_site do
    "http://www.lookupnote.io"
    # "http://localhost:4001"
  end

  def not_found_note do
    "demo.not_found"
  end
end