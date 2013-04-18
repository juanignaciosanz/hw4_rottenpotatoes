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

end
