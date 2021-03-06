
class RentalsController < ApplicationController
  before_action :find_customer, only: [:checkout, :checkin]
  before_action :find_movie, only: [:checkout, :checkin]

  def checkout
    unless Movie.checkout_inventory(@movie)
      render json: {errors: ["There are no copies of movie #{@movie.id} available"]}, status: :bad_request
      return
    end

    rental = Rental.new(movie_id: @movie.id, customer_id: @customer.id)
    cur_date = Date.today
    rental.checkout_date = cur_date
    rental.due_date = cur_date + 7

    if rental.save
      @customer.checkout_movies_count
      render json: {id: rental.id}, status: :ok
    else
      render json: {errors: rental.errors.messages},
             status: :bad_request
    end
  end

  def checkin
    successful = Movie.checkin_inventory(@movie, @customer)

    if successful
      render json: {ok: "Successfully checked in movie"}
    else
      render json: {errors: "This movie has not been checked out"}, status: :bad_request
    end
  end

  private

  def find_movie
    movie_id = params[:movie_id]
    @movie = Movie.find_by(id: movie_id)
    unless @movie
      render json: {errors: ["The movie with id #{movie_id} was not found"]}, status: :not_found
      return
    end
  end

  def find_customer
    customer_id = params[:customer_id]
    @customer = Customer.find_by(id: customer_id)

    unless @customer
      render json: {errors: ["The customer with id #{customer_id} was not found"]}, status: :not_found
      return
    end
  end
end
