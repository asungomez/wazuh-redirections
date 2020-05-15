require 'rails_helper'

RSpec.describe "branches/index", type: :view do
  before(:each) do
    assign(:branches, [
      Branch.create!(
        version: "Version"
      ),
      Branch.create!(
        version: "Version"
      )
    ])
  end

  it "renders a list of branches" do
    render
    assert_select "tr>td", text: "Version".to_s, count: 2
  end
end
