defmodule Tooba.Computer do
  @mac_topics ~w[
    SPAudioDataType
    SPCameraDataType
    SPHardwareDataType
    SPPowerDataType
    SPStorageDataType
  ]

  def mac_system_info do
    args = ["-json"] ++ @mac_topics

    with {json, 0} <- System.cmd("system_profiler", args) do
      Jason.decode(json)
    end
  end
end
