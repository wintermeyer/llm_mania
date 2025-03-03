namespace :ci do
  desc "Prepare database for CI testing"
  task prepare: :environment do
    begin
      # Try to create the database using Rails
      Rake::Task["db:create"].invoke
    rescue => e
      # If that fails, try direct psql approach
      puts "Rails db:create failed: #{e.message}"
      puts "Trying direct psql approach..."

      db_name = ENV.fetch("DATABASE_NAME", "llm_mania_test")
      host = ENV.fetch("POSTGRES_HOST", "localhost")
      user = ENV.fetch("POSTGRES_USER", "postgres")
      password = ENV.fetch("POSTGRES_PASSWORD", "postgres")
      port = ENV.fetch("POSTGRES_PORT", "5432")

      # Shell out to create the database with psql
      system({ "PGPASSWORD" => password }, "psql -h #{host} -p #{port} -U #{user} -c 'CREATE DATABASE #{db_name};'")
      raise "Failed to create database via psql" unless $?.success?
      puts "Database created via psql."
    end

    # Run migrations instead of loading schema
    puts "Running migrations..."
    Rake::Task["db:migrate"].invoke

    # Load seeds
    puts "Loading seeds..."
    Rake::Task["db:seed"].invoke

    puts "CI database prepared successfully!"
  end
end
