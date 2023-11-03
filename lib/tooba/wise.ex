defmodule Wise do
  @moduledoc """
  An API client for Wise (formerly TransferWise) using the Req library.
  """

  @base_url "https://api.transferwise.com/"
  @api_token System.get_env("WISE_API_TOKEN")
  @default_headers [
    {"Content-Type", "application/json"},
    {"Accept", "application/json"},
    {"Authorization", "Bearer #{@api_token}"}
  ]

  defp request do
    Req.new(base_url: @base_url, headers: @default_headers)
  end

  defp extract_body(response) do
    case response do
      {:ok, %Req.Response{body: body}} -> {:ok, body}
      {:error, _} = error -> error
    end
  end

  defp get(path, params \\ %{}) do
    request()
    |> Req.get(url: path, params: params)
    |> extract_body()
  end

  defp post(path, payload) do
    request()
    |> Req.post(url: path, json: payload)
    |> extract_body()
  end

  def list_profiles do
    get("/v2/profiles")
  end

  def list_currencies(profile_id) do
    get("/v2/borderless-accounts-configuration/profiles/#{profile_id}/available-currencies")
  end

  def create_quote(profile_id, quote_params) do
    post("/v3/profiles/#{profile_id}/quotes", quote_params)
  end

  def list_accounts(query_params) do
    get("/v2/accounts", query_params)
  end

  def transfer_requirements(transfer_details) do
    post("/v1/transfer-requirements", transfer_details)
  end

  def create_transfer(transfer_details) do
    post("/v1/transfers", transfer_details)
  end

  def example_usage do
    {:ok, [profile | _]} = list_profiles()
    {:ok, accounts} = list_accounts(%{profile: profile["id"]})
    account = accounts["content"] |> List.first()

    quote_params = %{
      profileId: profile["id"],
      sourceCurrency: "EUR",
      targetCurrency: "EUR",
      targetAmount: 100,
      targetAccount: account["id"],
      payOut: "BANK_TRANSFER"
    }

    {:ok, quote} = create_quote(profile["id"], quote_params)

    transfer_details = %{
      targetAccount: account["id"],
      quoteUuid: quote["id"],
      customerTransactionId: "12345",
      details: %{reference: "Test transfer"}
    }

    transfer_requirements(transfer_details)
  end
end
