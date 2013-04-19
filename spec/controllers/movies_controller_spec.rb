require 'spec_helper'

describe MoviesController do

  describe 'happy path: finding similar movies by director is ever possible' do

    before :each do
      @m = mock(Movie, :title => "Star Wars", :director => "George Lucas", :id => "1")
      Movie.stub!(:find).with("1").and_return(@m)
    end
    
    it 'should generate routing for Similar Movies' do
      { :get => movie_similar_path(1) }.
      should route_to(:controller => "movies", :action => "similar", :movie_id => "1")
    end
    it 'should receive the click on "Find Movies With Same Director"' do
      fake_results = [mock('Movie'), mock('Movie')]
      Movie.should_receive(:similar_director).with('George Lucas').and_return(fake_results)
      get :similar, :movie_id => "1"
    end
    it 'should select the Similar template for rendering and make results available' do
      Movie.stub!(:similar_director).with('George Lucas').and_return(@m)
      get :similar, :movie_id => "1"
      response.should render_template('similar')
      assigns(:movies).should == @m
    end
  end

  describe 'sad path: finding similar movies by director is never possible' do

    before :each do
      @m = mock(Movie, :title => "Star Wars", :director => nil, :id => "1")
      Movie.stub!(:find).with("1").and_return(@m)
    end
    
    it 'should generate routing for Similar Movies' do
      { :get => movie_similar_path(1) }.
      should route_to(:controller => "movies", :action => "similar", :movie_id => "1")
    end
    it 'should select the Index template for rendering and generate a flash' do
      get :similar, :movie_id => "1"
      response.should redirect_to(movies_path)
      flash[:notice].should_not be_blank
    end
  end


  describe 'Movie CRUD operations' do

    before :each do
      @m = mock(Movie, :title => "Star Wars", :director => nil, :id => "1")
    end
    
    describe 'create and destroy' do
      it 'should create a new movie' do
        MoviesController.stub(:create).and_return(mock('Movie'))
        post :create, {:id => "1"}
      end
      it 'should destroy a movie' do
        Movie.stub!(:find).with("1").and_return(@m)
        @m.should_receive(:destroy)
        delete :destroy, {:id => "1"}
      end
    end

    describe 'update' do
      it 'should pass movie object the new attribute value to updated and redirect' do
        fake_new_director = 'Steven Spielberg'
        Movie.stub!(:find).with("1").and_return(@m)
        @m.should_receive(:update_attributes!).with("director" => fake_new_director).and_return(true)
        put :update, :id => "1", :movie => {:director => fake_new_director}
        response.should redirect_to(movie_path(@m))
      end
    end

    describe 'read for showing and editing' do
      it 'should pass movie id and render movie' do
        Movie.stub!(:find).with("1").and_return(@m)
        get :show, :id => "1"
        response.should render_template('show')
      end
      it 'should pass movie id and render movie in editing template' do
        Movie.stub!(:find).with("1").and_return(@m)
        get :edit, :id => "1"
        response.should render_template('edit')
      end
    end
  end

  describe '#find_similar_movies' do

    before :each do
      @m = mock(Movie, :title => "Star Wars", :director => "George Lucas", :id => "1")
      Movie.stub!(:find).with("1").and_return(@m)
      @mn = mock(Movie, :title => "Star Wars", :director => nil, :id => "2")
      Movie.stub!(:find).with("2").and_return(@mn)
    end

    context 'when movie has no director info' do
      it 'should redirect to index template' do
        Movie.stub!(:similar_director).with(nil).and_return([])
        fake_movie = mock('Movie', :title => 'Fake Movie')
        Movie.stub!(:find_by_id).with("2").and_return(fake_movie)
        post :similar, {:movie_id => "2"}
        response.should redirect_to(movies_path)
      end
    end
    context 'when movie has director info' do
      before :each do
        @fake_movies = [mock('Movie'), mock('Movie')]
        Movie.stub!(:similar_director).with("George Lucas").and_return(@fake_movies)
      end
      it 'should render similar movies template' do
        post :similar, {:movie_id => "1"}
        response.should render_template('similar')
      end
      it 'should make the result of Movie.find_similar_movies available to that template' do
        post :similar, {:movie_id => "1"}
        assigns(:movies).should == @fake_movies
      end
    end
  end


  describe 'listing movies, sorting and filtering' do
    before :each do
      @fake_movies = [mock('Movie'), mock('Movie')]
    end
    it 'should make movies avaliable to template' do
      Movie.stub!(:find_all_by_rating).and_return(@fake_movies)
      get :index
      assigns(:movies).should == @fake_movies
      response.should render_template('index')
    end
    context 'should deal with sorting and ratings any' do
      before :each do
        @selected_ratings={:P => 'P'}
        session[:ratings]=@selected_ratings
        session[:sort]='any_different'
      end
      it 'should deal with sort title and ratings any' do
        get :index, {:sort => 'title', :ratings => @selected_ratings}
        assigns(:title_header).should == 'hilite'
        response.should redirect_to :sort => 'title', :ratings => @selected_ratings
      end
      it 'should deal with sort release_date and ratings any' do
        get :index, {:sort => 'release_date', :ratings => @selected_ratings}
        assigns(:date_header).should == 'hilite'
        response.should redirect_to :sort => 'release_date', :ratings => @selected_ratings
      end
    end
    context 'should deal with ratings and sorting any' do
      before :each do
        @selected_ratings={:P => 'P'}
        session[:ratings]=@selected_ratings
      end
      it 'should deal with ratings any and sort nil' do
        get :index, {:ratings => {:G=>'G'}}
        response.should redirect_to :ratings => {:G=>'G'}
      end
      it 'should deal with ratings any and sort any' do
        session[:sort]='any_valid'
        get :index, {:sort => 'title', :ratings => {:G=>'G'}}
        session[:ratings]={:G=>'G'}
        response.should redirect_to :sort => 'title', :ratings => {:G=>'G'}
      end
    end
  end

end
