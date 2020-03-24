defmodule Lab1.Application do
  use Application

    def start(_type, _args) do
    children = [
      %{
        id: DataFlow,
        start: {DataFlow, :start_link, [""]}
      },
      %{
        id: Distributor,
        start: {Distributor, :start_link, [""]}
      },
      %{
        id: Aggregator,
        start: {Aggregator, :start_link, [""]}
      },
      {
        DynSupervisor,
        []
      },
      %{
        id: Print,
        start: {Print, :start_link, []}
      },
      %{
        id: Request,
        start: {Request, :start_link, ["http://host.docker.internal:4000/iot"]}
      }
    ]

    opts = [strategy: :one_for_one, name: MainSupervisor]
    Supervisor.start_link(children, opts)
  end
end
