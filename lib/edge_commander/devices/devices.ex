defmodule EdgeCommander.Devices do
  @moduledoc """
  The Devices context.
  """

  import Ecto.Query, warn: false
  import EdgeCommander.Util, only: [parse_inner_array: 1, parse_single_element: 2]
  alias EdgeCommander.Repo
  require Logger
  require IEx

  alias EdgeCommander.Devices.Nvr

  def update_nvr_ISAPI(nvr)  do
    request_url = "#{nvr.ip}:#{nvr.port}/ISAPI/System/deviceInfo"
    hackney = [basic_auth: {"#{nvr.username}", "#{nvr.password}"}]

    dispatch_url_request(HTTPoison.get(request_url, [], hackney: hackney), nvr)
  end

  def dispatch_url_request({:ok,  %HTTPoison.Response{body: body}}, nvr) do
    prepare_changeset_for_ISAPI(body, nvr)
  end
  def dispatch_url_request(_, nvr), do: Logger.info "#{nvr.name} didnt respond for ISAPI."

  def prepare_changeset_for_ISAPI(body, nvr) do
    nvr
    |> Nvr.changeset(
      %{
        firmware_version: fetch_device_info(body, 'firmwareVersion'),
        model: fetch_device_info(body, 'model'),
        extra: %{
          device_name: fetch_device_info(body, 'deviceName'),
          device_id: fetch_device_info(body, 'deviceID'),
          serial_number: fetch_device_info(body, 'serialNumber'),
          mac_address: fetch_device_info(body, 'macAddress'),
          firmware_released_date: fetch_device_info(body, 'firmwareReleasedDate'),
          encoder_version: fetch_device_info(body, 'encoderVersion'),
          encoder_released_date: fetch_device_info(body, 'encoderReleasedDate'),
          device_type: fetch_device_info(body, 'deviceType')
        }
      }
    )
    |> Repo.update()
    |> declare_ISAPI_update
  end

  defp declare_ISAPI_update({:ok, updated_ISAPI_nvr}), do: Logger.info "#{updated_ISAPI_nvr.name} has been updated with ISAPI attrs."
  defp declare_ISAPI_update({:error, changeset}), do: Logger.info "Error: #{changeset}"

  def fetch_device_info(body, attr) do
    IEx.pry
    body
    |> parse_inner_array
    |> parse_single_element('/DeviceInfo/#{attr}')
  end

  @doc """
  Returns the list of nvrs.

  ## Examples

      iex> list_nvrs()
      [%Nvr{}, ...]

  """
  def list_nvrs do
    Repo.all(Nvr)
  end

  @doc """
  Gets a single nvr.

  Raises `Ecto.NoResultsError` if the Nvr does not exist.

  ## Examples

      iex> get_nvr!(123)
      %Nvr{}

      iex> get_nvr!(456)
      ** (Ecto.NoResultsError)

  """
  def get_nvr!(id), do: Repo.get!(Nvr, id)

  @doc """
  Creates a nvr.

  ## Examples

      iex> create_nvr(%{field: value})
      {:ok, %Nvr{}}

      iex> create_nvr(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_nvr(attrs \\ %{}) do
    %Nvr{}
    |> Nvr.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a nvr.

  ## Examples

      iex> update_nvr(nvr, %{field: new_value})
      {:ok, %Nvr{}}

      iex> update_nvr(nvr, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_nvr(%Nvr{} = nvr, attrs) do
    nvr
    |> Nvr.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Nvr.

  ## Examples

      iex> delete_nvr(nvr)
      {:ok, %Nvr{}}

      iex> delete_nvr(nvr)
      {:error, %Ecto.Changeset{}}

  """
  def delete_nvr(%Nvr{} = nvr) do
    Repo.delete(nvr)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking nvr changes.

  ## Examples

      iex> change_nvr(nvr)
      %Ecto.Changeset{source: %Nvr{}}

  """
  def change_nvr(%Nvr{} = nvr) do
    Nvr.changeset(nvr, %{})
  end
end
