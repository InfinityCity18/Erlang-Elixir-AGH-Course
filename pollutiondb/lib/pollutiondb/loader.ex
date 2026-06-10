defmodule Pollutiondb.Loader do
  def parse_line(line) do
    [date, type, value, id, stationname, coords] =
      line
      |> String.split(";")

    %{
      datetime: Kernel.elem(DateTime.from_iso8601(date), 1),
      location: List.to_tuple(coords |> String.split(",") |> Enum.map(&String.to_float/1)),
      stationId: String.to_integer(id),
      stationName: stationname,
      pollutionType: type,
      pollutionLevel: String.to_float(value)
    }
  end

  def load(path) do
    file_content = File.read!(path)

    file_content
    |> String.split("\n")
    |> Enum.filter(fn a -> a != "" end)
    |> Enum.map(&parse_line/1)
    |> Enum.each(fn %{
                      stationId: id,
                      stationName: name,
                      location: coords,
                      datetime: dt,
                      pollutionType: type,
                      pollutionLevel: level
                    } ->
      s =
        if Pollutiondb.Station.get_by_id(id) == nil do
          st = %Pollutiondb.Station{
            id: id,
            name: name,
            lon: elem(coords, 0),
            lat: elem(coords, 1)
          }

          elem(Pollutiondb.Station.add(st), 1)
        else
          Pollutiondb.Station.get_by_id(id)
        end

      Pollutiondb.Reading.add(
        s,
        DateTime.to_date(dt),
        Time.truncate(DateTime.to_time(dt), :second),
        type,
        level
      )
    end)
  end
end
