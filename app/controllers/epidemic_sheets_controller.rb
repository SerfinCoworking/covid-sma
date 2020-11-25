class EpidemicSheetsController < ApplicationController
  before_action :set_epidemic_sheet, only: [:show, :edit, :update, :destroy, :delete]

  # GET /epidemic_sheets
  # GET /epidemic_sheets.json
  def index
    @filterrific = initialize_filterrific(
      EpidemicSheet,
      params[:filterrific],
      select_options: {
        case_type: CaseDefinition.case_types.keys.map { |ct| [ct.humanize, ct] }
      },
      persistence_id: true,
      default_filter_params: {sorted_by: 'created_at_desc'},
    ) or return
    @epidemic_sheets = @filterrific.find.page(params[:page]).per_page(15)
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
    @epidemic_sheet.build_patient
    @epidemic_sheet.patient.build_address
    @epidemic_sheet.patient.build_current_address
    @epidemic_sheet.patient.patient_phones.build
  end

  # GET /epidemic_sheets/1/edit
  def edit
    @case_definitions = CaseDefinition.all
    @diagnostic_methods = DiagnosticMethod.all
  end

  # POST /epidemic_sheets
  # POST /epidemic_sheets.json
  def create
    @epidemic_sheet = EpidemicSheet.new(epidemic_sheet_params)
    @epidemic_sheet.created_by = current_user
    @epidemic_sheet.establishment = current_user.establishment
    @epidemic_sheet.update_or_create_address(patient_address_params)

    respond_to do |format|
      if @epidemic_sheet.save
        EpidemicSheetMovement.create(user: current_user, epidemic_sheet: @epidemic_sheet, action: "creó", sector: current_user.sector)
        format.html { redirect_to @epidemic_sheet, notice: 'La ficha epidemiológica se ha creado correctamente.' }
        format.json { render :show, status: :created, location: @epidemic_sheet }
      else
        @case_definitions = CaseDefinition.all
        @diagnostic_methods = DiagnosticMethod.all
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
        EpidemicSheetMovement.create(user: current_user, epidemic_sheet: @epidemic_sheet, action: "editó", sector: current_user.sector)
        format.html { redirect_to @epidemic_sheet, notice: 'La ficha epidemiológica se ha modificado correctamente.' }
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
      format.html { redirect_to epidemic_sheets_url, notice: 'La ficha epidemiológica se ha eliminado correctamente.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_epidemic_sheet
      @epidemic_sheet = EpidemicSheet.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def epidemic_sheet_update_params
      params.require(:epidemic_sheet).permit(
        :init_symptom_date, 
        :presents_symptoms, 
        :symptoms_observations, 
        :previous_symptoms, 
        :prev_symptoms_observations,
        :clinic_location,
        case_definition_attributes: [ 
          :id,
          :case_type,
          :diagnostic_method_id
        ]
      )
    end
    # Never trust parameters from the scary internet, only allow the white list through.
    def epidemic_sheet_params
      params.require(:epidemic_sheet).permit(
        :init_symptom_date, 
        :epidemic_week, 
        :presents_symptoms, 
        :symptoms_observations, 
        :previous_symptoms, 
        :prev_symptoms_observations,
        :clinic_location,
        case_definition_attributes: [ 
          :id,
          :case_type,
          :diagnostic_method_id
        ],
        patient_attributes: [ 
          :id,
          :dni,
          :last_name,
          :first_name,
          :sex,
          :birthdate,
          :status,
          patient_phones_attributes: [
            :id,
            :phone_type,
            :number
          ],
          current_address_attributes: [
            :neighborhood,
            :street,
            :street_number
          ],
        ]
      )
    end
    # Never trust parameters from the scary internet, only allow the white list through.
    def patient_address_params
      params.require(:epidemic_sheet).permit(
        patient_attributes:[
          address_attributes: [
            :country,
            :state,
            :city,
            :line,
            :latitude,
            :longitude,
            :postal_code
          ]
        ]
      )
    end
end
