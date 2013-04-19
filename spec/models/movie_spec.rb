require 'spec_helper'

describe Movie do
  describe 'provide different normalized ratings' do
    it 'should call Movie without parameters' do
      normalized_ratings = %w(G PG PG-13 NC-17 R)
      Movie.all_ratings.should == normalized_ratings
      assert Movie.all_ratings.any?, "There must be some ratings defined" 
    end
  end

  describe 'searching movies with similar director' do
    context 'when director is empty string' do
      it 'should return empty array' do
        fake_movie = mock('Movie', :director => '')
        Movie.similar_director(:director).should == []
      end
    end
    context 'when director is nil' do
      it 'should return empty array' do
        fake_movie = mock('Movie', :director => nil)
        Movie.similar_director(:director).should == []
      end
    end
    context 'when movie has a director' do
      it 'should call Movie with director' do
        fake_results = [mock('Movie'), mock('Movie')]
        Movie.stub!(:similar_director).with("Gearge Lucas").and_return(fake_results)
      end
    end
  end
end