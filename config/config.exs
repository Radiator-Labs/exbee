use Mix.Config

config :exbee, adapter: Exbee.CircuitsUARTAdapter

import_config "#{Mix.env()}.exs"
