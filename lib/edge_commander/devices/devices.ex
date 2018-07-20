defmodule EdgeCommander.Devices do
  @moduledoc """
  The Devices context.
  """
  import Ecto.Query, warn: false
  import EdgeCommander.Util, only: [parse_inner_array: 1, parse_single_element: 2]
  alias EdgeCommander.Repo
  require Logger
  alias EdgeCommander.Sharing.Member
  alias EdgeCommander.Devices.Nvr

  def update_nvr_ISAPI(nvr)  do
    request_url = "#{nvr.ip}:#{nvr.port}/ISAPI/System/deviceInfo"
    hackney = [basic_auth: {"#{nvr.username}", "#{nvr.password}"}, timeout: 50_000, recv_timeout: 50_000]

    HTTPoison.get(request_url, [], hackney: hackney)
    |> dispatch_url_request(nvr)
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

  def list_nvrs(user_id) do
    query = from n in Nvr,
      left_join: m in Member, on: n.user_id == m.account_id,
      where: (m.member_id == ^user_id or n.user_id == ^user_id)
    query
    |> order_by(:name)
    |>  Repo.all
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

  alias EdgeCommander.Devices.Router

  @doc """
  Returns the list of routers.

  ## Examples

      iex> list_routers()
      [%Router{}, ...]

  """

  def list_routers(user_id) do
    query = from r in Router,
      left_join: m in Member, on: r.user_id == m.account_id,
      where: (m.member_id == ^user_id or r.user_id == ^user_id)
    query
    |> order_by(:name)
    |>  Repo.all
  end

  @doc """
  Gets a single router.

  Raises `Ecto.NoResultsError` if the Router does not exist.

  ## Examples

      iex> get_router!(123)
      %Router{}

      iex> get_router!(456)
      ** (Ecto.NoResultsError)

  """
  def get_router!(id), do: Repo.get!(Router, id)

  @doc """
  Creates a router.

  ## Examples

      iex> create_router(%{field: value})
      {:ok, %Router{}}

      iex> create_router(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_router(attrs \\ %{}) do
    %Router{}
    |> Router.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a router.

  ## Examples

      iex> update_router(router, %{field: new_value})
      {:ok, %Router{}}

      iex> update_router(router, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_router(%Router{} = router, attrs) do
    router
    |> Router.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Router.

  ## Examples

      iex> delete_router(router)
      {:ok, %Router{}}

      iex> delete_router(router)
      {:error, %Ecto.Changeset{}}

  """
  def delete_router(%Router{} = router) do
    Repo.delete(router)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking router changes.

  ## Examples

      iex> change_router(router)
      %Ecto.Changeset{source: %Router{}}

  """
  def change_router(%Router{} = router) do
    Router.changeset(router, %{})
  end
end
