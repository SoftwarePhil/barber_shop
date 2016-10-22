defmodule BarberShop.Server do
  use GenServer
  alias BarberShop.Barber, as: Barber
  @cut_time 7000
  @arive_time 2000
  @moduledoc """
  This program is being written to learn about concurrency in elixir

  Shop Rules
  1. Barber shops have a set number of chairs in their
     waiting room
  2. Each shop has a set number of chairs for cutting
     customer's hair, this number  corresponds to how
     many barbers work in that shop
  3. A hair cut takes a set amount of time
  4. Once a customer's hair is done being cut they leave
     the shop, and barber who cutctheir hair goes to 'sleep'
  5. New customers arrive on based on a timer, if there
     is no open chair in the waiting room, the customer
     leaves
  6. If there is a free barber that is 'sleeping', they
     many take a customer and start cutting their hair
  """
  @name __MODULE__
  def start_link(barbers, chairs) do
    barber_list = make_barbers(barbers)
    shop_state = {barber_list, chairs}
    GenServer.start_link(@name, shop_state)
  end

  def make_barbers(amount) do
    1..amount
    |>Enum.to_list
    |>Enum.map(fn(id) -> Barber.init(@cut_time, self, id) end)
  end

end
