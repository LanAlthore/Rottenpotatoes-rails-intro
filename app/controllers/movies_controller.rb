class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default 
  end

  def index
    
    @all_ratings = ['G','PG','PG-13','R']
    @ratings = params[:ratings]
    
    if params[:sort]
      @sort_by = params[:sort]
      session[:sort_by]=params[:sort]
    elsif session[:sort_by]
      @sort_by = session[:sort_by]
    else
      @sort_by = nil
    end
    
    if @ratings
      @movies= Movie.where(ratings: params[:ratings].keys)
    end
  
    case @sort_by 
    when 'title'
      @movies = Movie.order('title ASC')
      @title_hilite = 'hilite'
    when 'release'
      @movies = Movie.order('release_date ASC')
      @release_hilite = 'hilite'
    else
      @ratings ? @movies = Movie.where(rating: params[:ratings].keys):
        @movies =Movie.all
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
