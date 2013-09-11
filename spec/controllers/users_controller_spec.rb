require 'spec_helper'

describe UsersController do
  render_views


  describe "follow pages" do

    describe "when not signed in" do

     it "should protect 'following'" do
        get(:following, :id => 1)
        response.should redirect_to(signin_path)
      end

      it "should protect 'followers'" do
        get(:followers, :id => 1)
        response.should redirect_to(signin_path)
      end

    end


    describe "when signed in" do

      before(:each) do
        @user = test_sign_in(FactoryGirl.create(:user))
        @other_user = FactoryGirl.create(:user, :email => FactoryGirl.generate(:email))
        @user.follow!(@other_user)
      end

      it "should allow a user to follow another user" do
        get(:following, :id => @user)
        response.should have_selector("a", :href => user_path(@other_user),
                                           :content => @other_user.name)
      end

      it "should show user followers" do
        get(:followers, :id => @other_user)
        response.should have_selector("a", :href => user_path(@user),
                                           :content => @user.name)
      end

    end

  end


  describe "DELETE 'destroy'" do

    before(:each) do
      @user = FactoryGirl.create(:user)
    end

    describe "as a user who is not signed in" do

      it "should deny access" do
        delete(:destroy, :id => @user)
        response.should redirect_to(signin_path)
      end

    end


    describe "as a user who does not have ADMIN privileges" do

      it "should protect the page" do
        test_sign_in(@user)
        delete(:destroy, :id => @user)
        response.should redirect_to(root_path)
      end

    end


    describe "as an ADMIN user" do

      before(:each) do
        @admin = FactoryGirl.create(:admin, :email => "admin@example.com")
        test_sign_in(@admin)
      end

      it "should destroy the user" do
        lambda do
          delete(:destroy, :id => @user)
        end.should change(User, :count).by(-1)
      end

      it "should redirect to the 'user' page" do
        delete(:destroy, :id => @user)
        response.should redirect_to(users_path)
      end

      it "should not be able to destroy its own account" do
        lambda do
          delete(:destroy, :id => @admin)
        end.should_not change(User, :count)
      end

      it "should show an error message when trying to destroy its own account" do
        delete(:destroy, :id => @admin)
        flash[:error].should =~ /cannot delete your own account/
      end

    end

  end


  describe "GET 'index'" do

    describe "for users who are not signed-in" do

      it "should deny access" do
        get(:index)
        response.should redirect_to(signin_path)
        flash[:notice].should =~ /sign in/i
      end

    end

    describe "for signed-in users" do

      before(:each) do
        @user = test_sign_in(FactoryGirl.create(:user))
        second = FactoryGirl.create(:user, :email => "another@example.com")
        third = FactoryGirl.create(:user, :email => "another@example.net")

        @users = [@user, second, third]

        30.times do
          @users << FactoryGirl.create(:user, :email => FactoryGirl.generate(:email))
        end
      end

      it "should be successful" do
        get(:index)
        response.should be_success
      end

      it "should have the right title" do
        get(:index)
        response.should have_selector("title", :content => "All Users")
      end

      it "should have an element for each user" do
        get(:index)

        @users[0..2].each do |user|
          response.should have_selector("li", :content => user.name)
        end
      end

      it "should paginate users" do
        get(:index)

        response.should have_selector("div.pagination")
        response.should have_selector("span.disabled", :content => "Previous")
        response.should have_selector("a", :href => "/users?page=2",
                                           :content => "2")
        response.should have_selector("a", :href => "/users?page=2",
                                           :content => "Next")
      end

      it "should not show 'delete' links" do
        get(:index)

        @users[0..29].each do |u|
          response.should_not have_selector("a", :href => "/users/#{ u.id }",
                                                 :content => "Delete")
        end
      end

      it "should show 'delete' links for admin users" do
        admin = FactoryGirl.create(:admin, :email => "admin@example.org")
        test_sign_in(admin)

        get(:index)

        @users[0..29].each do |u|
          response.should have_selector("a", :href => "/users/#{ u.id }",
                                             :content => "Delete")
        end
      end

    end

  end


  describe "GET 'show'" do
    before(:each) do
      @user = FactoryGirl.create(:user)
    end

    it "should be successful" do
      get(:show, :id => @user)
      response.should be_success
    end

    it "should find the right user" do
      get(:show, :id => @user)
      assigns(:user).should == @user
    end

    it "should have the right title" do
      get(:show, :id => @user)
      response.should have_selector("h1", :content => @user.name)
    end

    it "should have a profile image" do
      get(:show, :id => @user)
      response.should have_selector("h1 > img", :class => "gravatar")
    end

    it "should show the user's posts" do
      first_post = FactoryGirl.create(:micropost, :user => @user, :content => "This is not the post you're looking for.")
      second_post = FactoryGirl.create(:micropost, :user => @user, :content => "Opportunity star.")

      get(:show, :id => @user)

      response.should have_selector("span.content", :content => first_post.content)
      response.should have_selector("span.content", :content => second_post.content)
    end

  end


  describe "GET 'edit'" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      test_sign_in(@user)
    end

    it "should be successful" do
      get(:edit, :id => @user)
      response.should be_success
    end

    it "should have the right title" do
      get(:edit, :id => @user)
      response.should have_selector("title", :content => "Edit User")
    end

    it "should have a link to change the Gravatar" do
      get(:edit, :id => @user)
      gravatar_url = "http://gravatar.com/emails"
      response.should have_selector("a", :href => gravatar_url,
                                         :content => "change")
    end

  end


  describe "PUT 'edit'" do

    before(:each) do
      @user = FactoryGirl.create(:user)
      test_sign_in(@user)
    end

    describe "failure" do

      before(:each) do
        @attr = { :email => "",
                  :name => "",
                  :password => "",
                  :password_confirmation => "" }
      end

      it "should render the 'edit' page" do
        put(:update, :id => @user, :user => @attr)
        response.should render_template(:edit)
      end

      it "should have the right title" do
        put(:update, :id => @user, :user => @attr)
        response.should have_selector("title", :content => "Edit User")
      end

    end

    describe "success" do

      before(:each) do
        @attr = { :email => "user@example.org",
                  :name => "New Name",
                  :password => "barbaz",
                  :password_confirmation => "barbaz" }
      end

      it "should change the user's attributes" do
        put(:update, :id => @user, :user => @attr)

        @user.reload

        @user.name.should == @attr[:name]
        @user.email.should == @attr[:email]
      end

      it "should redirect to the user 'show' page" do
        put(:update, :id => @user, :user => @attr)
        response.should redirect_to(user_path(@user))
      end

      it "should have a flash message" do
        put(:update, :id => @user, :user => @attr)
        flash[:success].should =~ /updated/
      end

    end

  end


  describe "authentication of of edit/update pages" do

    before(:each) do
      @user = FactoryGirl.create(:user)
    end

    describe "for users who are not signed in" do

      it "should deny access to the 'edit' page" do
        get(:edit, :id => @user)
        response.should redirect_to(signin_path)
      end

      it "should deny access to the 'update' page" do
        get(:update, :id => @user, :user => {})
        response.should redirect_to(signin_path)
      end

    end

    describe "for signed-in users" do

      before(:each) do
        wrong_user = FactoryGirl.create(:user, :email => "user@example.net")
        test_sign_in(wrong_user)
      end

      it "should require matching users for 'edit'" do
        get(:edit, :id => @user)
        response.should redirect_to(root_path)
      end

      it "should require matching users for 'update'" do
        put(:update, :id => @user, :user => {})
        response.should redirect_to(root_path)
      end

    end

  end


  describe "GET 'new'" do
    it "returns http success" do
      get(:new)
      response.should be_success
    end

    it "should have User in the title" do
      get(:new)
      response.should have_selector("title", :content => "Sign Up")
    end

    it "should have a Name field" do
      get(:new)
      response.should have_selector("input[name='user[name]'][type='text']")
    end

    it "should have an Email field" do
      get(:new)
      response.should have_selector("input[name='user[email]'][type='text']")
    end

    it "should have a Password field" do
      get(:new)
      response.should have_selector("input[name='user[password]'][type='password']")
    end

    it "should have a Password Confirmation field" do
      get(:new)
      response.should have_selector("input[name='user[password_confirmation]'][type='password']")
    end

    describe "for signed-in users" do

      it "should redirect to the root" do
        user = FactoryGirl.create(:user)
        test_sign_in(user)

        get(:new)
        response.should redirect_to(root_path)
      end
    end

  end


  describe "POST 'create'" do

    describe "failure" do
      before(:each) do
        @attr = {:name => "",
                 :email => "",
                 :password => "",
                 :password_confirmation => ""
        }
      end

      it "should not create a user" do
        lambda do
          post(:create, :user => @attr)
        end.should_not change(User, :count)
      end

      it "should have the right title" do
        post(:create, :user => @attr)
        response.should have_selector("title", :content => "Sign Up")
      end

      it "should render the 'new' page" do
        post(:create, :user => @attr)
        response.should render_template('new')
        response.should have_selector("input[name='user[password]']", :content => "")
        response.should have_selector("input[name='user[password_confirmation]']", :content => "")
      end

      it "should have an empty Password field" do
        post(:create, :user => @attr)
        response.should have_selector("input[name='user[password]']", :content => "")
      end

      it "should have an empty Password Confirmation field" do
        post(:create, :user => @attr)
        response.should have_selector("input[name='user[password_confirmation]']", :content => "")
      end
    end

    describe "success" do
      before(:each) do
        @attr = {:name => "New User",
                 :email => "newuser@foo.com",
                 :password => "foobar",
                 :password_confirmation => "foobar"
        }
      end

      it "should create a user" do
        lambda do
          post(:create, :user => @attr)
        end.should change(User, :count).by(1)
      end

      it "should redirect to the user 'show' page" do
        post(:create, :user => @attr)
        response.should redirect_to(user_path(assigns(:user)))
      end

      it "should have a welcome message" do
        post(:create, :user => @attr)
        flash[:success].should =~ /welcome to the sample app/i
      end

      it "should sign the user in" do
        post(:create, :user => @attr)
        controller.should be_signed_in
      end
    end

  end

end
