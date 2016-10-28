# BarberShop

This program is being written to learn about concurrency in elixir
  
  to run: 
  	 iex> BarberShop.Agent.start_link 2,4

  (3 barbers, with 5 seats)
  other params in BarberShop.Agent module

  *note BarberShop.Server module can also be used if the Server alias is changed in shop.ex

  ##Shop Rules
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

