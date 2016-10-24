defmodule BarberShop.Barber do
@moduledoc """
  This module acts like a barber, it takes a customer,
  and cuts their hair.

  1. A barber can only cut one customer's hair at a time
  2. After a barber has finished cutting a customer's hair
  they go to 'sleep'
"""

#have to think more about how to handle barbers
##we know what who the next customer is,
##we don't know which barber is free,
##I think that should be tracked by
##ShopServer, this will act like chairs does
  def init(time, shop_pid, id) do
    spawn(__MODULE__, :cut_hair, [time, shop_pid, id])
  end

  def cut_hair(time, shop_pid, id) do
    receive do
      {:customer, customer_id} ->
        IO.puts "baber #{id} cutting #{customer_id}'s hair"
        send shop_pid, {:cutting, id}

        :timer.sleep(time)

        IO.puts "barber #{id} is done cutting #{customer_id}'s hair"
        send shop_pid, {:cutting_done, id}

      {:sleep} ->
        IO.puts "barber #{id} sleeping"
        send shop_pid, {:sleeping, id}
    end
    cut_hair(time, shop_pid, id)
  end
end
