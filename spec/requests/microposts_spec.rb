require 'spec_helper'

describe "Microposts" do

  before(:each) do
    user = FactoryGirl.create(:user)

    visit(signin_path)

    fill_in(:email, :with => user.email)
    fill_in(:email, :with => user.password)

    click_button
  end

  describe "creation" do

    describe "failure" do

      it "should not make a new Micropost" do
        lambda do
          visit(root_path)

          fill_in('micropost_content', :with => "")

          click_button

          response.should render_template('pages/home')
          response.should have_selector("div#error_explanation")
        end.should_not change(Micropost, :count)
      end

    end

    describe "success" do

      it "should create a new Micropost" do
        content = "This is some test content"

        lambda do
          visit(root_path)

          fill_in('micropost_content', :with => content)

          click_button

          response.should have_selector("span.content", :content => content)
        end.should change(Micropost, :count).by(1)
      end

    end

  end

end
