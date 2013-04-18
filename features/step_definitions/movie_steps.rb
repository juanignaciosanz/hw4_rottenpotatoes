# Add a declarative step here for populating the DB with movies.

Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
    # each returned element will be a hash whose key is the table header.
    # you should arrange to add that movie to the database here.
    Movie.create!(movie)
  end
end

# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  #  ensure that that e1 occurs before e2.
  #  page.body is the entire content of the page as a string.
  assert page.body.match(/<td>#{e1}<\/td>(\s|\S)+<td>#{e2}<\/td>/), "Wrong movie order"
end

# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

When /I (un)?check the following ratings: (.*)/ do |uncheck, rating_list|
  # HINT: use String#split to split up the rating_list, then
  #   iterate over the ratings and reuse the "When I check..." or
  #   "When I uncheck..." steps in lines 89-95 of web_steps.rb
  rating_list.split(/, */).each do |rating|
    unless uncheck
      step %{I check "ratings[#{rating}]"}
    else
      step %{I uncheck "ratings[#{rating}]"}
    end
  end
end

# For the scenario all ratings selected, it would be tedious to 
# use "And I should see" to name every single movie. That would detract from 
# the goal of BDD to convey the behavioral intent of the user story. To fix this, 
# create step definitions in movie_steps.rb that will match steps of the form

Then /^I should see all of the movies$/ do
  assert page.should have_selector("table tr", :count => Movie.count + 1), "Not all movies have seen"
end

# Check the director for a movie applies

Then /^the director of "([^"]*)" should be "([^"]*)"$/ do |arg1, arg2|
  Movie.find_by_title(arg1).director == arg2
  assert page.should have_content("Director: #{arg2}")
end