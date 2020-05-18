require 'rails_helper'

RSpec.describe "pages/edit", type: :view do
  before(:each) do
    @page = assign(:page, Page.create!(
      path: "MyString",
      branch: nil
    ))
  end

  it "renders the edit page form" do
    render

    assert_select "form[action=?][method=?]", page_path(@page), "post" do

      assert_select "input[name=?]", "page[path]"

      assert_select "input[name=?]", "page[branch_id]"
    end
  end
end
