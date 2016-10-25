defmodule BarberShop.Shop do
@moduledoc """
  This module acts like a shop.  It can take in new cutomers,
  and remove customers from the waiting room. it also starts
  a process which adds new customers to the waiting room
"""
alias BarberShop.Server, as: Server

  def init(max, time, num \\ 1) do
    spawn(__MODULE__, :arive, [max, time, num])
    Server.next_haircut
  end

  def arive(max, time, num) when max > 0 do
    Server.new_customer(num)
    IO.puts "new customer #{num} has arived"
    :timer.sleep(time)
    arive(max - 1, time, num + 1)
  end

  def arive(0, _time, num) do
    IO.puts "No more cutomers will arive, all #{num - 1} customers have arived"
  end

#list = [{1, :empty, nil}, {2, :empty, nil}, {3, :empty, nil}, {4, :empty, nil}]
#new_customer(list, 1)
#[{1, :full, 1}, {2, :empty, nil}, {3, :empty, nil}, {4, :empty, nil}]
  def add_customer(chairs, customer) do
    add_customer(chairs, customer, [])
  end

  defp add_customer([{n, :empty, nil}|t], customer, new_chairs) do
    list = new_chairs ++ [{n, :full, customer}] ++ t
    IO.inspect "customer #{customer} has sat in seat #{n}"
    list
  end

  defp add_customer([seat = {_n, :full, _m}| t], customer, new_chairs) do
    list = new_chairs ++ [seat]
    add_customer(t, customer, list)
  end

  defp add_customer([], customer, new_chairs) do
    IO.inspect "customer #{customer} has left, no seats in waiting room"
    new_chairs
  end

  #write get next customer function
  def next_customer(chairs) do
    next_customer(chairs, [])
  end

  defp next_customer([seat = {_n, :empty, nil}|t], new_chairs) do
    next_customer(t, new_chairs ++ [seat])
  end

  defp next_customer([{n, :full, m}|t], new_chairs) do
    list = new_chairs ++ [{n, :empty, nil}] ++ t
    IO.inspect "customer #{m} has left seat #{n} to get a hair cut"
    {list, {:customer, m}}
  end

  defp next_customer([], new_chairs) do
    {new_chairs, :none}
  end
end
