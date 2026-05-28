# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
Rails.logger.info "ENV: #{Rails.env}"
Rails.logger.info "Table exists: #{ActiveRecord::Base.connection.table_exists?(:users)}"
Rails.logger.info "Column exists: #{ActiveRecord::Base.connection.column_exists?(:users, :email)}"
Rails.logger.info "Email env: #{ENV["SEED_USER_EMAIL"].present?}"

if Rails.env.production? &&
   ActiveRecord::Base.connection.table_exists?(:users) &&
   ActiveRecord::Base.connection.column_exists?(:users, :email)
  User.find_or_create_by(email: ENV["SEED_USER_EMAIL"]) do |u|
    u.password = ENV["SEED_USER_PASSWORD"]
    u.password_confirmation = ENV["SEED_USER_PASSWORD"]
  end
end
