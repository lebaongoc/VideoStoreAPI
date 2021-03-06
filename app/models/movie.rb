class Movie < ApplicationRecord
  validates :title, presence: true
  validates :inventory, presence: true, numericality: {only_integer: true, greater_than: 0}

  has_many :rentals

  def self.checkout_inventory(movie)
    if movie.available_inventory >= 1
      movie.available_inventory -= 1
      movie.save
    else
      return false
    end
  end

  def self.checkin_inventory(movie, customer)
    if movie.available_inventory < movie.inventory && Customer.checkin_movies_count(customer)
      movie.available_inventory += 1
      movie.save
    else
      return false
    end
  end
end
