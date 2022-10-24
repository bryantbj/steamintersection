IO.puts("Processing .iex.exs file 👍")

alias SteamIntersection.{
  Steam,
  Steam.Api,
  Steam.Library,
  Steam.Profile
  # Accounts,
  # Accounts.User,
  # BankAccounts,
  # BankAccounts.BankAccount,
  # BankAccounts.Transaction,
  # Repo,
}

defmodule Constants do
  def popbumpers_id() do
    "76561198085395935"
  end
end


import_if_available(Ecto.Query)

import_if_available(Ecto.Changeset)
