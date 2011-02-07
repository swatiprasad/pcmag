Then /^(?:|I )should not see "([^"]*)" under "([^"]*)"/ do |text, heading|
  begin
    find("##{heading.parameterize('_')}").should have_no_content(text)
  rescue Capybara::ElementNotFound
    find("#submission_#{Submission.find_by_title(heading).id}").should have_no_content(text)
  end
end

Then /^(?:|I )should see "([^"]*)" under "([^"]*)"/ do |text, heading|
  begin
    find("##{heading.parameterize('_')}").should have_content(text)
  rescue Capybara::ElementNotFound
    find("#submission_#{Submission.find_by_title(heading).id}").should have_content(text)
  end
end

Then /^(?:|I )should see a "([^"]*)" link under "([^"]*)"/ do |text, heading|
  find("section##{heading.parameterize('_')}").find("a", :text => text)
end

Given /^(?:there is )a person named "([^"]*)" with email address "([^"]*)"$/ do |name, email|
  name = name.split
  Person.create(
    :first_name => name.first,
    :last_name  => name.last,
    :email      => email,
    :password   => 'secret',
    :password_confirmation => 'secret')
end
