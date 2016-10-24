defmodule BarberShop.BarberTest do
  use ExUnit.Case, async: true
  alias BarberShop.Barber, as: Barber

  test "new barber is set to busy after haircut is done" do
    #make a barber list where they are all "busy"
    barber_list = 1..4 |>Enum.map(fn(id) -> {Barber.init(2000, id), :busy} end)
    #get the first barber
    {:ok, barber} = Enum.fetch(barber_list, 0)
    {pid, _status} = barber

    new_barber_list = Barber.barber_done(barber_list, barber)
    {:ok, barber2} = Enum.fetch(new_barber_list, 0)

    assert {pid, :free} == barber2
  end

end
