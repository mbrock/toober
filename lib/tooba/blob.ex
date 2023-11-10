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

  # Saves a blob to the file system with a file name based on the content hash and returns the hash.
  def save_blob(data) do
    ensure_data_dir_exists()
    file_name = generate_content_hash(data)
    file_path = blob_store_file_path(file_name)

    case File.write(file_path, data) do
      :ok -> {:ok, file_name}
      {:error, reason} -> {:error, reason}
    end
  end

  # Generates a SHA256 hash of the given data.
  defp generate_content_hash(data) do
    :crypto.hash(:sha256, data)
    |> Base.encode16(case: :lower)
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
