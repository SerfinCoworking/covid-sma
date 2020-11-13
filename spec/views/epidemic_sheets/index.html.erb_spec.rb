require 'rails_helper'

RSpec.describe "epidemic_sheets/index", type: :view do
  before(:each) do
    assign(:epidemic_sheets, [
      EpidemicSheet.create!(
        :patient => nil,
        :case_definition => nil,
        :epidemic_week => 2,
        :presents_sumptoms => false,
        :symptoms_observations => "MyText",
        :previous_symptoms => false,
        :prev_symptoms_observations => "MyText",
        :clinic_location => 3
      ),
      EpidemicSheet.create!(
        :patient => nil,
        :case_definition => nil,
        :epidemic_week => 2,
        :presents_sumptoms => false,
        :symptoms_observations => "MyText",
        :previous_symptoms => false,
        :prev_symptoms_observations => "MyText",
        :clinic_location => 3
      )
    ])
  end

  it "renders a list of epidemic_sheets" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
  end
end
