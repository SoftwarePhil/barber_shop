defmodule BarberShop.BarberTest do
  use ExUnit.Case, async: true
  alias BarberShop.Barber, as: Barber

  test "barber that is done is to free after haircut is done" do
    #make a barber list where they are all "busy"
    barber_list = 1..4 |>Enum.map(fn(id) -> {Barber.init(2000, id), :busy} end)
    #get the first barber
    {:ok, barber} = Enum.fetch(barber_list, 3)
    {pid, _status} = barber

    new_barber_list = Barber.barber_done(barber_list, barber)
    IO.inspect new_barber_list
    {:ok, barber2} = Enum.fetch(new_barber_list, 3)


    assert {pid, :free} == barber2
  end

  test "testing that when next haircut is called, the barber has the correct state" do
    #make a barber list where none are busy
    barber_list = 1..2 |>Enum.map(fn(id) -> {Barber.init(20000, id), :free} end)
    #chairs with some customers in them
    {:ok, barber1} = Enum.fetch(barber_list, 0)
    {:ok, barber2} = Enum.fetch(barber_list, 1)

    {pid1, _status1} = barber1
    {pid2, _status2} = barber2

    {:ok, l1} = Barber.next_haircut(barber_list, 1)
    {:ok, l2} = Barber.next_haircut(l1, 2)
    {:fail, l3} = Barber.next_haircut(l2, 3)
    {:fail, l4} = Barber.next_haircut(l3, 4)

    IO.inspect l4

    assert l4 == [{pid1, :busy}, {pid2, :busy}]
  end

end
