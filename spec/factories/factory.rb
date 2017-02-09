# See https://github.com/thoughtbot/factory_girl/blob/master/GETTING_STARTED.md#configure-your-test-suite for information

FactoryGirl.define do
  # # Defining examples
  # factory :user do
  #   first_name "John"
  #   last_name  "Doe"
  #   admin false
  # end

  # # This will use the User class (Admin would have been guessed)
  # factory :admin, class: User do
  #   first_name "Admin"
  #   last_name  "User"
  #   admin      true
  # end
end




# # USE EXAMPLES: 

# # Returns a User instance that's not saved
# user = build(:user)

# # Returns a saved User instance
# user = create(:user)

# # Returns a hash of attributes that can be used to build a User instance
# attrs = attributes_for(:user)

# # Returns an object with all defined attributes stubbed out
# stub = build_stubbed(:user)

# # Passing a block to any of the methods above will yield the return object
# create(:user) do |user|
#   user.posts.create(attributes_for(:post))
# end