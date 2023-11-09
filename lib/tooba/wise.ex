defmodule Tooba.Wise do
  use Tesla

  @base_url "https://api.transferwise.com/"
  @api_token System.get_env("WISE_API_TOKEN")

  plug Tesla.Middleware.BaseUrl, @base_url

  plug Tesla.Middleware.Headers, [
    {"Content-Type", "application/json"},
    {"Accept", "application/json"},
    {"Authorization", "Bearer #{@api_token}"}
  ]

  plug Tesla.Middleware.JSON

  def list_profiles do
    get("/v2/profiles")
    |> handle_response()
  end

  def list_currencies(profile_id) do
    get("/v2/borderless-accounts-configuration/profiles/#{profile_id}/available-currencies")
    |> handle_response()
  end

  def create_quote(profile_id, quote_params) do
    post("/v3/profiles/#{profile_id}/quotes", quote_params)
    |> handle_response()
  end

  def list_accounts(query_params) do
    get("/v2/accounts", query: query_params)
    |> handle_response()
  end

  def transfer_requirements(transfer_details) do
    post("/v1/transfer-requirements", transfer_details)
    |> handle_response()
  end

  def create_transfer(transfer_details) do
    post("/v1/transfers", transfer_details)
    |> handle_response()
  end

  defp handle_response(response) do
    case response do
      {:ok, %Tesla.Env{status: 200, body: body}} -> {:ok, body}
      {:error, _} = error -> error
    end
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
