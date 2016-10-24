defmodule BarberShop.Server do
  use GenServer
  alias BarberShop.Barber, as: Barber
  alias BarberShop.Shop, as: Shop
  @cut_time 7000
  @arive_time 2000
  @total_customers 10
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
  def handle_call({:init, shop_state}, _from, []) do
    {:reply, {:set, shop_state}, shop_state}
  end

  def handle_cast({:new_customer, customer}, {barber_list, chairs}) do
    {:noreply, {barber_list, Shop.add_customer(chairs, customer)}}
  end

#client
@name __MODULE__
  def start_link(barbers, chairs) do
    {:ok, pid} = GenServer.start_link(__MODULE__, [], name: @name)

    barber_list = 1..barbers |>Enum.to_list |>Enum.map(fn(id) -> Barber.init(@cut_time, pid, id) end)
    chair_list  = 1..chairs |>Enum.to_list |>Enum.map(fn(id) -> {id, :empty, nil} end)
    shop_state  = {barber_list, chair_list}
    GenServer.call(@name, {:init, shop_state})

    IO.inspect shop_state
    Shop.init(@total_customers, @arive_time)

    pid
  end

#when a new customer arives, this gets called
  def new_customer(customer) do
    GenServer.cast(@name, {:new_customer, customer})
  end

end
