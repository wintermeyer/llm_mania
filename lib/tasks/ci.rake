namespace :ci do
  desc "Prepare database for CI testing"
  task prepare: :environment do
    # Create database and load schema
    Rake::Task["db:create"].invoke
    Rake::Task["db:schema:load"].invoke
    
    # Load seeds (important for our user creation tests)
    Rake::Task["db:seed"].invoke
    
    puts "CI database prepared successfully!"
  end
end 