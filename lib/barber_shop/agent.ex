defmodule BarberShop.Agent do
  @moduledoc """
    This module will do the same thing as BarberShop.Server except,
    it will use an Agent to store state instead of a GenServer
  """
  alias BarberShop.BarberAgent, as: Barber
  alias BarberShop.Shop, as: Shop
  @cut_time 4500
  @arive_time 1000
  @total_customers 5
  @name __MODULE__

  def start_link(barbers, chairs) do
    pid = spawn(__MODULE__, :haircut_sync, [])
    barber_list = 1..barbers |>Enum.map(fn(id) -> {Barber.init(@cut_time, id, pid), :free} end)
    chair_list  = 1..chairs  |>Enum.map(fn(id) -> {id, :empty, nil} end)
    shop_state  = {barber_list, chair_list}
    {:ok, _another_pid} = Agent.start_link(fn->shop_state end, name: @name)

    Shop.init(@total_customers, @arive_time)
  end

#this allows calls to next_hair cut function to be synced up
#before the same state was being to two barbers, and things were
#getting messed up
  def haircut_sync do
    receive do
      :next_haircut ->
        :ok = BarberShop.Agent.next_haircut
    end
    haircut_sync
  end

  def next_haircut() do
    state = {barber_list, chairs} = Agent.get(@name, fn state-> state end)
    IO.inspect state

    case Shop.next_customer(chairs) do
      {_new_chairs, :none} ->
        #no customers are in waiting room
        :ok
      {new_chairs, {:customer, id}}->
        case Barber.next_haircut(barber_list, id) do
          {:ok, new_barber_list} -> #good
            Agent.update(@name, fn _state -> {new_barber_list, new_chairs} end)
            :ok
          {:fail, _new_list} ->
            #no barber available to cut hair
            :ok
        end
      end
  end

  #when a new customer arives, this gets called
  #thoughts, this is harder to use when no using a struct or something
  def new_customer(customer) do
    Agent.update(@name, fn({barber_list, chairs}) ->
                            {barber_list, Shop.add_customer(chairs, customer)}
                        end)
  end

  def barber_done(barber) do
    Agent.update(@name, fn({barber_list, chairs}) ->
                            {Barber.barber_done(barber_list, barber), chairs}
                        end)
  end
end
