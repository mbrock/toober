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
      {:ok, {:mac, Jason.decode!(json)}}
    end
  end

  def system_info!() do
    {:ok, info} = mac_system_info()
    info
  end

  def unique_iri({:mac, info}) do
    [hardware] = info["SPHardwareDataType"]
    serial_number = hardware["serial_number"]
    RDF.IRI.new!("http://node.town/devices/apple/#{serial_number}")
  end

  def unique_iri() do
    unique_iri(Application.get_env(:tooba, :system_info))
  end
end
