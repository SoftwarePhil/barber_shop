defmodule BarberShop.BarberAgent do
@moduledoc """
  This module acts like a barber, it is given a customer,
  and cuts their hair. Each barber is it's own process
  and cuts a customer's hair when a message is received.
  The barber checks for new customers by asking the
  BarberShop for a new customer's hair to cut by calling
  Server.next_haircut.

  1. A barber can only cut one customer's hair at a time
  2. After a barber has finished cutting a customer's hair
  they go to 'sleep'
"""

alias BarberShop.Agent, as: Server

  def init(time, id, pid) do
    spawn(__MODULE__, :cuthair, [time, id, pid])
  end

  def cuthair(time, id, pid) do
    receive do
      {:customer, customer_id} ->
        IO.puts "barber #{id} cutting #{customer_id}'s hair"
        #send shop_pid, {:cutting, id}

        :timer.sleep(time)

        IO.puts "barber #{id} is done cutting #{customer_id}'s hair"
        #send shop_pid, {:cutting_done, id} # need a GenServer cast to set state to free again

        #this is conufsing because, when the haircut is done,
        #the server being send this busy barber,
        #the barber gets marked as being free in the servers list
        #by calling barber_done function
        Server.barber_done({self, :busy})

        #Server.next_haircut
        send pid, :next_haircut

    after 1000 ->
      send pid, :next_haircut
    end

    cuthair(time, id, pid)
  end

@doc"""
  This function returns a new list of barbers,
  where the barber is marked as 'busy' and
  the barber's process is passed a new customer.

  This function the key function that relates
  the barber and customer together.
"""
  def next_haircut(barber_list, customer_id) do
    next_haircut(barber_list, customer_id, [])
  end

  defp next_haircut([_barber = {pid, :free}|t], customer_id, new_list) do
    send pid, {:customer, customer_id}
    {:ok, new_list ++ [{pid, :busy}] ++ t}
  end

  defp next_haircut([barber = {_pid, :busy}|t], customer_id, new_list) do
    next_haircut(t, customer_id, new_list ++ [barber])
  end

  defp next_haircut([], _customer_id, new_list) do
    {:fail, new_list}
  end

@doc"""
used to mark a barber :free after they complete a haircut
so that they can cut another clients hair
"""
  def barber_done(barber_list, barber) do
    barber_done(barber_list, barber, [])
  end

  defp barber_done([{pid, :busy}|t], _barber = {pid, :busy}, new_list) do
    new_list ++ [{pid, :free}] ++ t
  end

  defp barber_done([h | t], barber, new_list) do
    barber_done(t, barber, new_list ++ [h])
  end
end
