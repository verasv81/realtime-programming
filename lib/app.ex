defmodule Lab1.Application do
  use Application

  @registry :workers_registry

  def start(_type, _args) do
    children = [
      {
        Registry,
        [keys: :unique, name: @registry]
      },
      {
        DynSupervisor,
        []
      },
      %{
        id: Request,
        start: {Request, :start_link, ["http://localhost:4000/iot"]}
      },
      %{
        id: Aggregator,
        start: {Aggregator, :start_link, []}
      },
      %{
        id: Distributor,
        start: {Distributor, :recv, []}
      },
      %{
        id: DataFlow,
        start: {DataFlow, :start_link, []}
      }
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end
end
