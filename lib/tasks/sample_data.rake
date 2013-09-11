require 'faker'

namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do

    # Call db:reset to blow out the existing data in the database.
    Rake::Task['db:reset'].invoke
    make_users
    make_microposts
    make_relationships
  end
end


# Build some users to populate the database with sample data.
def make_users
  # Build two admin users
  admin = User.create!(:name => "Example User",
                       :email => "example@railstutorial.org",
                       :password => "foobar",
                       :password_confirmation => "foobar")

  admin.toggle!(:admin)

  vader = User.create!(:name => "Darth Vader",
                       :email => "bigdaddyv@deathstar.com",
                       :password => "foobar",
                       :password_confirmation => "foobar")

  vader.toggle!(:admin)

  # Build 99 other users, using Faker to generate random names. (I got 99 users, but my bitch ain't one...)
  99.times do |n|
    name = Faker::Name.name
    email = "example-#{ n + 1 }@railstutorial.org"
    password = "password"

    User.create!(:name => name,
                 :email => email,
                 :password => password,
                 :password_confirmation => password)
  end
end

# Build some microposts to associate to Users that are created by the make_users method.
def make_microposts
  # Generate 50 posts for 6 users.  Use Faker to generate some content for the Microposts.
  50.times do
    User.all(:limit => 6).each do |user|
      user.microposts.create!(:content => Faker::Lorem.sentence(5))
    end
  end
end

# Create some follower and following relationships for the first user created in the make_users method.
def make_relationships
  users = User.all
  user = users.first

  following = users[1..50]  # all of the other users our first user should be following.
  followers = users[3..40]  # all of the users that are following our first user.

  following.each { |followed| user.follow!(followed) }
  followers.each { |follower| follower.follow!(user) }
end
