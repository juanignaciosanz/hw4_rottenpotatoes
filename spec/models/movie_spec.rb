require 'spec_helper'

describe Movie do
  describe 'searching movies with similar director' do
    it 'should call Movie with director' do
      Movie.should_receive(:similar_director).with('George Lucas')
      Movie.similar_director('George Lucas')
    end
  end
end
