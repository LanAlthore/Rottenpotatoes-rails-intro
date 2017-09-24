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
    if(!params.has_key?(:sort) && !params.has_key?(:ratings))
      if(session.has_key?(:sort) || session.has_key?(:ratings))
        redirect_to movies_path(:sort=>session[:sort], :ratings=>session[:ratings])
      end
    end
    @sort = params.has_key?(:sort) ? (session[:sort] = params[:sort]) : session[:sort]
    @all_ratings = Movie.all_ratings.keys
    @ratings = params[:ratings]
    if(@ratings != nil)
      ratings = @ratings.keys
      session[:ratings] = @ratings
    else
      if(!params.has_key?(:commit) && !params.has_key?(:sort))
        ratings = Movie.all_ratings.keys
        session[:ratings] = Movie.all_ratings
      else
        ratings = session[:ratings].keys
      end
    end
    @movies = Movie.order(@sort).find_all_by_rating(ratings)
    @mark  = ratings

  end
    
    if redirect
      flash.keep
      redirect_to movies_path :sort_by=>@sort_by, :ratings=>@ratings
    end  
    
    if @ratings and @sort_by
      case @sort_by
      when 'title'
        @movies = Movie.where(:rating => @ratings.keys).order('title ASC')
        @title_hilite = 'hilite'
      when 'release'
        @movies = Movie.where(:rating => @ratings.keys).order('release_date ASC')
        @release_hilite = 'hilite'
      end
    elsif @ratings
      @movies = Movie.where(:rating => @ratings.keys)
    elsif @sort_by
      case @sort_by
        when 'title'
          @movies = Movie.order('title ASC')
          @title_hilite = 'hilite'
        when 'release'
          @movies = Movie.order('release_date ASC')
          @release_hilite = 'hilite'
      end
    else
      @movies = Movie.all
    end
    
    if !@ratings
      @ratings = Hash.new
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
