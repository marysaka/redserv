defmodule RedservEx.Application do
  @moduledoc false

  use Application
  import Supervisor.Spec

  def start(_type, _args) do
    children = [
      :ranch.child_spec(:ranch_redis, :ranch_tcp, [{:port, 6380}], RedservEx.Protocol, []),
      supervisor(RedservEx.PubSub, [])
    ]
    opts = [strategy: :one_for_one, name: RedservEx.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
