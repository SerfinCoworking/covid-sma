require 'rails_helper'

RSpec.describe "epidemic_sheets/new", type: :view do
  before(:each) do
    assign(:epidemic_sheet, EpidemicSheet.new(
      :patient => nil,
      :case_definition => nil,
      :epidemic_week => 1,
      :presents_sumptoms => false,
      :symptoms_observations => "MyText",
      :previous_symptoms => false,
      :prev_symptoms_observations => "MyText",
      :clinic_location => 1
    ))
  end

  it "renders new epidemic_sheet form" do
    render

    assert_select "form[action=?][method=?]", epidemic_sheets_path, "post" do

      assert_select "input[name=?]", "epidemic_sheet[patient_id]"

      assert_select "input[name=?]", "epidemic_sheet[case_definition_id]"

      assert_select "input[name=?]", "epidemic_sheet[epidemic_week]"

      assert_select "input[name=?]", "epidemic_sheet[presents_sumptoms]"

      assert_select "textarea[name=?]", "epidemic_sheet[symptoms_observations]"

      assert_select "input[name=?]", "epidemic_sheet[previous_symptoms]"

      assert_select "textarea[name=?]", "epidemic_sheet[prev_symptoms_observations]"

      assert_select "input[name=?]", "epidemic_sheet[clinic_location]"
    end
  end
end
