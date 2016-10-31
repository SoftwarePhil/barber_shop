defmodule BarberShop.Shop do
@moduledoc """
  This module acts like a shop.  It can take in new cutomers,
  and remove customers from the waiting room. it also starts
  a process which adds new customers to the waiting room

  if using GenServer, uncomment line 9, comment line 10
"""
alias BarberShop.Server, as: Server
#alias BarberShop.Agent, as: Server

  def init(max, time, num \\ 1) do
    spawn(__MODULE__, :arive, [max, time, num])
    Server.next_haircut
  end

@doc """
  A process that adds new customers to the waiting room after some
  amount of time has passed
"""
  def arive(max, time, num) when max > 0 do
    IO.puts "new customer #{num} has arrived"
    Server.new_customer(num)
    :timer.sleep(time)
    arive(max - 1, time, num + 1)
  end

  def arive(0, _time, num) do
    IO.puts "No more customers will arrive, all #{num - 1} customers have arrived"
  end

  def add_customer(chairs, customer) do
    add_customer(chairs, customer, [])
  end

  defp add_customer([{n, :empty, nil}|t], customer, new_chairs) do
    list = new_chairs ++ [{n, :full, customer}] ++ t
    IO.puts "customer #{customer} has sat in seat #{n}"
    list
  end

  defp add_customer([seat = {_n, :full, _m}| t], customer, new_chairs) do
    list = new_chairs ++ [seat]
    add_customer(t, customer, list)
  end

  defp add_customer([], customer, new_chairs) do
    IO.puts "customer #{customer} has left, no seats in waiting room"
    new_chairs
  end

@doc """
This function takes the next avaible customer and removes them from the list
of customers in the waiting room, returning the customer who left thier chair
and the new list of chairs, returns list and :none waiting room is empty
"""
  def next_customer(chairs) do
    next_customer(chairs, [])
  end

  defp next_customer([seat = {_n, :empty, nil}|t], new_chairs) do
    next_customer(t, new_chairs ++ [seat])
  end

  defp next_customer([{n, :full, m}|t], new_chairs) do
    list = new_chairs ++ [{n, :empty, nil}] ++ t
    IO.puts "customer #{m} has left seat #{n} to get a haircut"
    {list, {:customer, m}}
  end

  defp next_customer([], new_chairs) do
    {new_chairs, :none}
  end
end
