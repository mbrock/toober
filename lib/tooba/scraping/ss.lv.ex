defmodule Tooba.Scraping.SSLV do
  def fetch() do
    url = "https://www.ss.com/lv/real-estate/flats/riga/centre/rss/"
    Req.get!(url).body
  end

  import Meeseeks.CSS

  def parse_rss(body) do
    xml = Meeseeks.parse(body, :xml)

    for item <- Meeseeks.all(xml, css("item")) do
      IO.inspect(item)
      title = Meeseeks.one(item, css("title"))
      link = Meeseeks.one(item, css("link"))
      pub_date = Meeseeks.one(item, css("pubDate"))
      description = Meeseeks.one(item, css("description"))

      # Parse HTML within description
      html_data = parse_html_description(Meeseeks.text(description))

      %{
        "@context" => "https://schema.org",
        "@type" => "Apartment",
        "url" => Meeseeks.text(link),
        "datePublished" => Meeseeks.text(pub_date),
        "offers" => %{
          "@type" => "Offer"
        }
      }
    end
  end

  defp parse_html_description(html) do
    table =
      html
      |> String.replace("<br/>", "@@@")
      |> Meeseeks.parse()
      |> Meeseeks.one(css("body"))
      |> Meeseeks.text()
      |> String.split(" @@@")
      |> Enum.filter(&String.contains?(&1, ": "))
      |> Enum.map(&String.split(&1, ": "))
      |> Enum.map(fn [k, v] -> {k, v} end)
      |> Enum.filter(fn {k, _v} -> k != "" end)
      |> Enum.into(%{})

    url = Meeseeks.one(html, css("a")) |> Meeseeks.attr("href")
    img = Meeseeks.one(html, css("img")) |> Meeseeks.attr("src")

    Map.merge(table, %{image: img, url: url})
  end
end
