defmodule BarberShop.Server do
  use GenServer
  alias BarberShop.Barber, as: Barber
  alias BarberShop.Shop, as: Shop
  @cut_time 6000
  @arive_time 1000
  @total_customers 25
  @moduledoc """
  This program is being written to learn about concurrency in elixir
  to run: iex> BarberShop.Server.start_link 3,5

  (3 barbers, with 5 seats)
  other params in BarberShop.Server module

  Shop Rules
  1. Barber shops have a set number of chairs in their
     waiting room
  2. Each shop has a set number of chairs for cutting
     customer's hair, this number  corresponds to how
     many barbers work in that shop
  3. A hair cut takes a set amount of time
  4. Once a customer's hair is done being cut they leave
     the shop, and barber who cut their hair goes to 'sleep'
  5. New customers arrive on based on a timer, if there
     is no open chair in the waiting room, the customer
     leaves
  6. If there is a free barber, they many take a customer
     and start cutting their hair
  """
  def handle_call({:init, shop_state}, _from, []) do
    {:reply, {:set, shop_state}, shop_state}
  end

  def handle_cast({:new_customer, customer}, {barber_list, chairs}) do
    {:noreply, {barber_list, Shop.add_customer(chairs, customer)}}
  end

  def handle_cast({:haircut_done, barber}, {barber_list, chairs}) do
    {:noreply, {Barber.barber_done(barber_list, barber), chairs}}
  end

  def handle_cast({:barber_done, barber}, {barber_list, chair_list}) do
    {:noreply, {Barber.barber_done(barber_list, barber), chair_list}}
  end

#problem is next customer should not be called until a barber is ready.
#this is a bad way to 'run' the shop
  def handle_cast(:next_haircut, state = {barber_list, chairs}) do
    #IO.inspect state
    case Shop.next_customer(chairs) do
      {_new_chairs, :none} ->
        {:noreply, {barber_list, chairs}}
      {new_chairs, {:customer, id}}->
        case Barber.next_haircut(barber_list, id) do
          {:ok, new_barber_list} -> #good
            {:noreply, {new_barber_list, new_chairs}}
          {:fail, _new_list} -> #no barber available
            {:noreply, {barber_list, chairs}}
        end
      end
  end

#client
@name __MODULE__

#with a run shop process I think this will be done, should write other tests
  def start_link(barbers, chairs) do
    {:ok, pid} = GenServer.start_link(__MODULE__, [], name: @name)

    barber_list = 1..barbers |>Enum.map(fn(id) -> {Barber.init(@cut_time, id), :free} end)
    chair_list  = 1..chairs  |>Enum.map(fn(id) -> {id, :empty, nil} end)
    shop_state  = {barber_list, chair_list}
    GenServer.call(@name, {:init, shop_state})

    IO.inspect shop_state
    Shop.init(@total_customers, @arive_time)

    pid
  end


#called when we want a next hair cut
  def next_haircut() do
    GenServer.cast(@name, :next_haircut)
  end
#when a new customer arives, this gets called
  def new_customer(customer) do
    GenServer.cast(@name, {:new_customer, customer})
  end

  def haircut_done(barber) do
    GenServer.cast(@name, {:haircut_done, barber})
  end

  def barber_done(barber) do
    GenServer.cast(@name, {:barber_done, barber})
  end

end
