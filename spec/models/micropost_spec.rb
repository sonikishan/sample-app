# == Schema Information
#
# Table name: microposts
#
#  id         :integer          not null, primary key
#  content    :string(255)
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Micropost do

  before(:each) do
    @user = FactoryGirl.create(:user)
    @attr = { :content => "some incredibly valuable content" }
  end

  it "should create a new Micropost given valid attributes" do
    @user.microposts.create!(@attr)
  end


  describe "from users followed by" do

    before(:each) do
      @other_user = FactoryGirl.create(:user, :email => FactoryGirl.generate(:email))
      @third_user = FactoryGirl.create(:user, :email => FactoryGirl.generate(:email))

      @user_post = @user.microposts.create!(:content => "foo")
      @other_post = @other_user.microposts.create!(:content => "bar")
      @third_post = @third_user.microposts.create!(:content => "baz")

      @user.follow!(@other_user)
    end

    it "should have a from_users_followed_by class method" do
      Micropost.should respond_to(:from_users_followed_by)
    end

    it "should include the followed user's Microposts" do
      Micropost.from_users_followed_by(@user).should include(@other_post)
    end

    it "should include the user's own Microposts" do
      Micropost.from_users_followed_by(@user).should include(@user_post)
    end

    it "should not include Microposts from a user that isn't being followed" do
      Micropost.from_users_followed_by(@user).should_not include(@third_post)
    end

  end


  describe "users associations" do

    before(:each) do
      @micropost = @user.microposts.create(@attr)
    end

    it "should have a 'user' attribute" do
      @micropost.should respond_to(:user)
    end

    it "should have the right associated user" do
      @micropost.user_id.should == @user.id
      @micropost.user.should == @user
    end

  end


  describe "validations" do

    it "should require a user id" do
      Micropost.new(@attr).should_not be_valid
    end

    it "should require non-empty content" do
      @user.microposts.build(:content => " ").should_not be_valid
    end

    it "should not allow more than 140 characters for content" do
      @user.microposts.build(:content => "a" * 141).should_not be_valid
    end

  end

end
