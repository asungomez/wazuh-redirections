require 'rails_helper'

RSpec.describe "pages/index", type: :view do
  before(:each) do
    assign(:pages, [
      Page.create!(
        path: "Path",
        branch: nil
      ),
      Page.create!(
        path: "Path",
        branch: nil
      )
    ])
  end

  it "renders a list of pages" do
    render
    assert_select "tr>td", text: "Path".to_s, count: 2
    assert_select "tr>td", text: nil.to_s, count: 2
  end
end
