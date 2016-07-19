class MoviesController < ApplicationController
  before_action :set_movie, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show]


  # create_table "movies", force: :cascade do |t|
  #   t.string   "title"
  #   t.text     "description"
  #   t.string   "movie_length"
  #   t.string   "director"
  #   t.string   "rating"
  #   t.datetime "created_at",         null: false
  #   t.datetime "updated_at",         null: false
  #   t.integer  "user_id"
  #   t.string   "image_file_name"
  #   t.string   "image_content_type"
  #   t.integer  "image_file_size"
  #   t.datetime "image_updated_at"
  # end
  def search
    if params[:search].present?
      @movies = Movie.search(params[:search], limit: 1000)
      if @movies.empty?
        url = "http://www.omdbapi.com/?t=#{params[:search]}"
        response = HTTParty.get(url)
        Movie.create!({
          title: response['Title'],
          image_file_name: response['Poster'],
          rating: response['Rated']
          })
      end
    else
      @movies = Movie.all
    end
  end

  def index
    @movies = Movie.all
  end

  def show
    @reviews = Review.where(movie_id: @movie.id).order("created_at DESC")

    if @reviews.blank?
      @avg_review = 0
    else
      @avg_review = @reviews.average(:rating).round(2)
    end
  end

  def new
    @movie = current_user.movies.build
  end

  def edit
  end

  def create
    @movie = current_user.movies.build(movie_params)

    respond_to do |format|
      if @movie.save
        format.html { redirect_to @movie, notice: 'Movie was successfully created.' }
        format.json { render :show, status: :created, location: @movie }
      else
        format.html { render :new }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @movie.update(movie_params)
        format.html { redirect_to @movie, notice: 'Movie was successfully updated.' }
        format.json { render :show, status: :ok, location: @movie }
      else
        format.html { render :edit }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @movie.destroy
    respond_to do |format|
      format.html { redirect_to movies_url, notice: 'Movie was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_movie
      @movie = Movie.find(params[:id])
    end

    def movie_params
      params.require(:movie).permit(:title, :description, :movie_length, :director, :rating, :image)
    end
end
