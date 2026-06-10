defmodule Pollutiondb.Reading do
  use Ecto.Schema
  require Ecto.Query

  schema "readings" do
    field(:date, :date)
    field(:time, :time)
    field(:type, :string)
    field(:value, :float)
    belongs_to(:station, Pollutiondb.Station)
  end

  def find_by_date(date) do
    Ecto.Query.from(r in Pollutiondb.Reading,
      where: r.date == ^date
    )
    |> Pollutiondb.Repo.all()
  end

  def add(station, date, time, type, value) do
    station
    |> Ecto.build_assoc(:readings, %{
      date: date,
      time: time,
      type: type,
      value: value
    })
    |> Pollutiondb.Repo.insert()
  end

  def add_now(station, type, value) do
    station
    |> Ecto.build_assoc(:readings, %{
      date: Date.utc_today(),
      time: Time.utc_now(),
      type: type,
      value: value
    })
    |> Pollutiondb.Repo.insert()
  end
end
