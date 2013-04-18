require 'spec_helper'

describe Movie do
  describe 'provide different normalized ratings' do
    it 'should call Movie without parameters' do
      Movie.should_receive(:all_ratings).and_return(%w(G PG PG-13 NC-17 R))
      assert Movie.all_ratings.any?, "There must be some ratings defined" 
    end
  end

  describe 'searching movies with similar director' do
    it 'should call Movie with director' do
      Movie.should_receive(:similar_director).with('George Lucas')
      Movie.similar_director('George Lucas')
    end
  end
end
