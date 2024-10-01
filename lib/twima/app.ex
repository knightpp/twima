defmodule Twima.App do
  use Ecto.Schema
  import Ecto.Changeset

  schema "apps" do
    field :client_id, :string
    field :client_secret, :string
    field :url, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(app, attrs \\ %{}) do
    app
    |> cast(attrs, [:client_id, :client_secret, :url])
    |> validate_required([:client_id, :client_secret, :url])
  end
end
