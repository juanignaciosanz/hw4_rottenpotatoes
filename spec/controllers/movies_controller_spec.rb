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

end
