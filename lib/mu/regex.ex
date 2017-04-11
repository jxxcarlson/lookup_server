defmodule MU.Regex do

  @moduledoc """
  MU.Regex is a library of regexes used for the MU markup language.
"""

  def unordered_list_item_regex do
    ~r/^[\*|-] (\S.*)$/m
  end

  @doc """
  SECTION: link regexes (used in mu/link.ex)
"""

  def audio_player_regex do
    ~r/(http|https):\/\/(.*(mp3|wav))/i
  end

  def hyperlink_bare_regex do
    ~r/\s((http|https):\/\/([a-zA-Z0-9\.\-_%-']*)([\/?=#]\S*|))\s/
  end

  def hyperlink_formatted_regex do
    ~r/\s(((http|https):\/\/[a-zA-Z0-9\.\-\/&=~\?#!@_%-']*)\[(.*)\])[^\]]/U
  end

  def image_bare_regex do
    ~r/(http|https):\/\/(.*(png|jpg|jpeg|gif))(\s|$)/i
  end

  def image_regex_formatted do
    ~r/((http|https):\/\/(.*(png|jpg|jpeg|gif)))\[(.*)\]/i
  end

  def pdf_regex do
    ~r/display::((http|https):(.*(pdf)))\s/U
  end

  def site_link_regex do
    ~r/site:(.*)\[(.*)\]/U
  end

  def xref_regex do
    ~r/xref::(.*)\[(.*)\]/U
  end

  def youtube_regex do
    ~r/(https:\/\/youtu.be\/(.*))($|\s)/rU
  end

end