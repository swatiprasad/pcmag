# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Pc::Application.initialize!

# Needs to be set for submissions to turn out right!
Haml::Template.options[:ugly] = true

Sass::Plugin.options[:css_location] = 'public/stylesheets/compiled'
