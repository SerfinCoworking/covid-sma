class EpidemicSheetsController < ApplicationController
  before_action :set_epidemic_sheet, only: [:show, :edit, :update, :destroy]

  # GET /epidemic_sheets
  # GET /epidemic_sheets.json
  def index
    @epidemic_sheets = EpidemicSheet.all
  end

  # GET /epidemic_sheets/1
  # GET /epidemic_sheets/1.json
  def show
  end

  # GET /epidemic_sheets/new
  def new
    @epidemic_sheet = EpidemicSheet.new
    @case_definitions = CaseDefinition.all
    @epidemic_sheet.build_case_definition
    @diagnostic_methods = DiagnosticMethod.all
  end

  # GET /epidemic_sheets/1/edit
  def edit
  end

  # POST /epidemic_sheets
  # POST /epidemic_sheets.json
  def create
    @epidemic_sheet = EpidemicSheet.new(epidemic_sheet_params)

    respond_to do |format|
      if @epidemic_sheet.save
        format.html { redirect_to @epidemic_sheet, notice: 'Epidemic sheet was successfully created.' }
        format.json { render :show, status: :created, location: @epidemic_sheet }
      else
        format.html { render :new }
        format.json { render json: @epidemic_sheet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /epidemic_sheets/1
  # PATCH/PUT /epidemic_sheets/1.json
  def update
    respond_to do |format|
      if @epidemic_sheet.update(epidemic_sheet_params)
        format.html { redirect_to @epidemic_sheet, notice: 'Epidemic sheet was successfully updated.' }
        format.json { render :show, status: :ok, location: @epidemic_sheet }
      else
        format.html { render :edit }
        format.json { render json: @epidemic_sheet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /epidemic_sheets/1
  # DELETE /epidemic_sheets/1.json
  def destroy
    @epidemic_sheet.destroy
    respond_to do |format|
      format.html { redirect_to epidemic_sheets_url, notice: 'Epidemic sheet was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_epidemic_sheet
      @epidemic_sheet = EpidemicSheet.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def epidemic_sheet_params
      params.require(:epidemic_sheet).permit(:patient_id, :case_definition_id, :init_symptom_date, :epidemic_week, :presents_sumptoms, :symptoms_observations, :previous_symptoms, :prev_symptoms_observations, :clinic_location)
    end
end
