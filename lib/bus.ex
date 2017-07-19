defmodule Bus do
  @moduledoc """
  Documentation for Bus.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Bus.hello
      :world

  """
  def hello do
    :world
  end
  
  def get(ymd) do 
    url = "www.btransit.org/rss.aspx?type=4&cat=37&custom=791"
    body = HTTPoison.get!(url).body
    File.write("/home/knathan2/Documents/bus/lib/service.html", body)
    {:ok, feed, _} = FeederEx.parse(body)
    entries = Enum.map(feed.entries, fn entry -> {entry.title, entry.updated} end)

    userTime = ymd <> "T00:00:00+00:00"
    {:ok, userTime, 0} = DateTime.from_iso8601(userTime)

    result = compTime(userTime, entries, "")
    result
  end

  defp compTime(date1, list, pStatus) do 
    [head|tail] = list
    status = elem(head, 0)
    date2 = toDate(head)
    case DateTime.compare(date1, date2) do
      :gt ->
        compTime(date1, tail, status)
      :lt ->
        pStatus
      :eq ->
        if String.contains?(status, "BT") do 
          compTime(date1, tail, status)
        else
          status
        end
    end
  end

  defp toDate(head) do
    origTime = elem(head, 1)
    if String.contains?(origTime, "-0700") do 
      origTime = String.replace(origTime, "-0700", "GMT")
    else
      origTime = String.replace(elem(head, 1), "-0800", "GMT")
    end
    {:ok, newTime} = Timex.parse(origTime, "{RFC1123}")
    newTime
  end

end
