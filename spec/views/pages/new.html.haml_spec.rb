require 'rails_helper'

RSpec.describe "pages/new", type: :view do
  before(:each) do
    assign(:page, Page.new(
      path: "MyString",
      branch: nil
    ))
  end

  it "renders new page form" do
    render

    assert_select "form[action=?][method=?]", pages_path, "post" do

      assert_select "input[name=?]", "page[path]"

      assert_select "input[name=?]", "page[branch_id]"
    end
  end
end
