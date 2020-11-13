require 'rails_helper'

RSpec.describe "epidemic_sheets/show", type: :view do
  before(:each) do
    @epidemic_sheet = assign(:epidemic_sheet, EpidemicSheet.create!(
      :patient => nil,
      :case_definition => nil,
      :epidemic_week => 2,
      :presents_sumptoms => false,
      :symptoms_observations => "MyText",
      :previous_symptoms => false,
      :prev_symptoms_observations => "MyText",
      :clinic_location => 3
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/3/)
  end
end
