source 'https://rubygems.org'


# -------------------------------------    Universal gems   -----------------------------------------------

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.4'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Websockets
gem 'redis', '~> 3.0'

# Sass and coffee syntaxes for CSS and JS in Rails 
gem 'sass-rails', '~> 5.0'
gem 'coffee-rails', '~> 4.2'

#Javascript minifier
gem 'uglifier', '>= 1.3.0'

# Turbolinks makes navigating your web application faster using Ajax requests
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'


# -------------------------------------    Project specific gems   ----------------------------------------

# Secure authentication
gem 'devise'
gem 'bcrypt', '~> 3.1.7'
gem 'hashids' #generate hashed ids

# Styles
gem 'bootstrap', '~> 4.0.0'
gem "select2-rails"
gem 'jquery-rails'

# Delayed jobs => schedule tasks
gem 'delayed_job_active_record'

# ---------------------------------------------------------------------------------------------------------

group :development, :test do
  # Use sqlite3 as the database for Active Record
  gem 'sqlite3'

  # Storing environment variables
  gem 'dotenv-rails', '~> 2.1', '>= 2.1.1'
  
  # Testing
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rails-controller-testing'
  gem 'annotate'
  
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Debugging
  gem 'meta_request' # Rails tab in the Chrome inspector
  gem 'pry-rails'
  gem 'awesome_print'
  gem "better_errors" # Better trace, source code inspection and console
  gem "binding_of_caller" # Advanced features for better_errors
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# ---------------------------------------------------------------------------------------------------------

group :production do 
  gem 'pg', '0.20.0'
end 