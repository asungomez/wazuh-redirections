require 'rails_helper'

RSpec.describe "pages/show", type: :view do
  before(:each) do
    @page = assign(:page, Page.create!(
      path: "Path",
      branch: nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Path/)
    expect(rendered).to match(//)
  end
end
