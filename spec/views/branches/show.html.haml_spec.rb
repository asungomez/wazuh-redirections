require 'rails_helper'

RSpec.describe "branches/show", type: :view do
  before(:each) do
    @branch = assign(:branch, Branch.create!(
      version: "Version"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Version/)
  end
end
