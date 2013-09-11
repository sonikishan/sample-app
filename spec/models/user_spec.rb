# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  encrypted_password :string(255)
#  salt               :string(255)
#  admin              :boolean          default(FALSE)
#

require 'spec_helper'

describe User do

  before(:each) do
    @attr = {
        :name => "Some User",
        :email => "user@example.com",
        :password => "password",
        :password_confirmation => "password"
    }
  end

  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end

  it "should require a name" do
    user_without_name = User.new(@attr.merge(:name => ""))
    user_without_name.should_not be_valid
  end

  it "should require an e-mail address" do
    user_without_email = User.new(@attr.merge(:email => ""))
    user_without_email.should_not be_valid
  end

  it "should reject names that are too long" do
    long_name = "foo" * 20
    long_name_user = User.new(@attr.merge(:name => long_name))
    long_name_user.should_not be_valid
  end

  it "should accept valid e-mail addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end

  it "should reject invalid e-mail addresses" do
    addresses = %w[user@foo,com THE_USER_at_foo.org first.last.jp.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end

  it "should reject duplicate e-mail addresses" do
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

  it "should reject duplicate e-mail addresses (case-insensitive)" do
    upper_case_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upper_case_email))
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end


  describe "admin attribute" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "should respond to admin" do
      @user.should respond_to(:admin)
    end

    it "should not be an admin by default" do
      @user.should_not be_admin
    end

    it "should be convertible to admin" do
      @user.toggle!(:admin)
      @user.should be_admin
    end

  end


  describe "micropost associations" do

    before(:each) do
      @user = User.create(@attr)
      @first_post = FactoryGirl.create(:micropost, :user => @user, :created_at => 1.day.ago)
      @second_post = FactoryGirl.create(:micropost, :user => @user, :created_at => 1.hour.ago)
    end

    it "should have a 'microposts' attribute" do
      @user.should respond_to(:microposts)
    end

    it "should have the right microposts in the right order" do
      @user.microposts.should == [@second_post, @first_post]
    end

    it "should destroy associated Microposts when the User is destroyed" do
      @user.destroy

      [@first_post, @second_post].each do |micropost|
        Micropost.find_by_id(micropost.id).should be_nil
      end
    end


    describe "status feed" do
      it "should have a feed" do
        @user.should respond_to(:feed)
      end

      it "should include a user's microposts" do
        @user.feed.include?(@first_post).should be_true
        @user.feed.include?(@second_post).should be_true
      end

      it "should not include a different user's microposts" do
        @third_post = FactoryGirl.create(:micropost,
                                         :user => FactoryGirl.create(:user, :email => FactoryGirl.generate(:email)))

        @user.feed.should_not include(@third_post)
      end

      it "should include Microposts from users that are being followed" do
        user_being_followed = FactoryGirl.create(:user, :email => FactoryGirl.generate(:email))
        post_from_followed_user = FactoryGirl.create(:micropost, :user => user_being_followed)

        @user.follow!(user_being_followed)

        @user.feed.should include(post_from_followed_user)
      end

    end

  end


  describe "password validations" do

    it "should require a password" do
      User.new(@attr.merge(:password => "", :password_confirmation => "")).should_not be_valid
    end

    it "should reject short passwords" do
      short_pass = "a" * 5
      User.new(@attr.merge(:password => short_pass, :password_confirmation => short_pass)).should_not be_valid
    end

    it "should reject long passwords" do
      long_pass = "a" * 41
      User.new(@attr.merge(:password => long_pass, :password_confirmation => long_pass)).should_not be_valid
    end

  end


  describe "password encryption" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end

    it "should set the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end

    describe "'has_password?' method" do

      it "should return true if the User has a password assigned" do
        @user.has_password?(@attr[:password]).should be_true
      end

      it "should return false if the User has no password assigned" do
        @user.has_password?("invalid").should be_false
      end

    end


    describe "authenticate method" do

      it "should return nil on email/password mismatch" do
        wrong_password_user = User.authenticate(@attr[:email], "wrongpass")
        wrong_password_user.should be_nil
      end

      it "should return nil for an email address with no user" do
        nonexistent_user = User.authenticate("fakeemail@example.com", @attr[:password])
        nonexistent_user.should be_nil
      end

      it "should return the user when the e-mail/password combination match" do
        valid_user = User.authenticate(@attr[:email], @attr[:password])
        valid_user.should == @user
      end

    end

  end


  describe "relationships" do

    before(:each) do
      @user = User.create!(@attr)
      @followed = FactoryGirl.create(:user)
    end

    it "should have a relationship method" do
      @user.should respond_to(:relationships)
    end

    it "should have a following method" do
      @user.should respond_to(:following)
    end

    it "should have a following? method" do
      @user.should respond_to(:following?)
    end

    it "should have a follow! method" do
      @user.should respond_to(:follow!)
    end

    it "should follow another user" do
      @user.follow!(@followed)
    end

    it "should include the followed user in the following array" do
      @user.follow!(@followed)

      @user.following.should include(@followed)
    end

    it "should have an unfollow! method" do
      @user.should respond_to(:unfollow!)
    end

    it "should be able to no longer follow a user" do
      @user.follow!(@followed)
      @user.unfollow!(@followed)

      @user.following.should_not include(@followed)
    end

  end

end
