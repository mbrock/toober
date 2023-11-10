defmodule Tooba.Blob.Store do
  @moduledoc """
  A hash-based content-addressable store for binary data,
  stored in the file system within the user data directory.
  """

  # Helper function to ensure the storage directory exists.
  defp ensure_data_dir_exists do
    data_home = get_xdg_data_home()
    :ok = File.mkdir_p(data_home)
  end

  # Helper function to generate file paths.
  defp blob_store_file_path(file_name) do
    Path.join([get_xdg_data_home(), file_name])
  end

  # Returns the XDG data home path.
  defp get_xdg_data_home do
    :filename.basedir(:user_data, Application.get_application(:tooba) |> Atom.to_string())
  end

  # Saves a blob to the file system.
  def save_blob(file_name, data) do
    ensure_data_dir_exists()
    file_path = blob_store_file_path(file_name)

    File.write(file_path, data)
  end

  # Retrieves a blob from the file system.
  def get_blob(file_name) do
    file_path = blob_store_file_path(file_name)

    if File.exists?(file_path) do
      File.read(file_path)
    else
      {:error, :not_found}
    end
  end
end
