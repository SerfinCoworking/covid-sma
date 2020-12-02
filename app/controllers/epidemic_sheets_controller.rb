class EpidemicSheetsController < ApplicationController
  before_action :set_epidemic_sheet, only: [:show, :edit, :update, :destroy, :delete]
  before_action :set_epidemic_sheet_symptoms, only: [:new, :create, :edit, :update]

  def dashboard
    _helper = ActiveSupport::NumberHelper
    _epidemic_sheets_today = EpidemicSheet.current_day
    _epidemic_sheets_month = EpidemicSheet.current_month
    @epidemic_sheets = EpidemicSheet.all
    @count_epidemic_sheets_today = _epidemic_sheets_today.count
    @count_epidemic_sheets_month = _epidemic_sheets_month.count
    @last_epidemic_sheets = @epidemic_sheets.order(created_at: :desc).limit(5)
  end

  # GET /epidemic_sheets
  # GET /epidemic_sheets.json
  def index
    @filterrific = initialize_filterrific(
      EpidemicSheet,
      params[:filterrific],
      select_options: {
        case_status: CaseStatus.all.select(:name, :id)
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
    @epidemic_sheet.build_case_definition
    @epidemic_sheet.build_patient
    @epidemic_sheet.patient.build_address
    @epidemic_sheet.patient.build_current_address
    @epidemic_sheet.patient.patient_phones.build
  end
  
  # GET /epidemic_sheets/1/edit
  def edit
  end

  # POST /epidemic_sheets
  # POST /epidemic_sheets.json
  def create
    @epidemic_sheet = EpidemicSheet.new(epidemic_sheet_params)
    @epidemic_sheet.created_by = current_user
    @epidemic_sheet.establishment = current_user.establishment
    @epidemic_sheet.update_or_create_address(patient_address_params)

    respond_to do |format|
      if @epidemic_sheet.save!
        EpidemicSheetMovement.create(user: current_user, epidemic_sheet: @epidemic_sheet, action: "creó", sector: current_user.sector)
        # @epidemic_sheet.case_definition.record_case_evolution
        format.html { redirect_to @epidemic_sheet, notice: 'La ficha epidemiológica se ha creado correctamente.' }
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
      if @epidemic_sheet.update!(epidemic_sheet_params)
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
    
    def set_epidemic_sheet_symptoms
      @symptoms = Symptom.all.sort_by &:name
      @previous_symptoms = PreviousSymptom.all.sort_by &:name
      @occupations = Occupation.all.sort_by &:name
      @case_definitions = CaseDefinition.all
      @diagnostic_methods = DiagnosticMethod.all
      @establishments = Establishment.all.sort_by &:name
      @special_devices = SpecialDevice.all.sort_by &:name
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def epidemic_sheet_update_params
      params.require(:epidemic_sheet).permit(
        :occupation_id,
        :init_symptom_date, 
        :presents_symptoms, 
        :symptoms_observations, 
        :present_previous_symptoms, 
        :prev_symptoms_observations,
        :clinic_location,
        symptom_ids: [],
        previous_symptom_ids: [],
        case_definition_attributes: [ 
          :id,
          :case_status_id,
          :special_device_id,
          :diagnostic_method_id
        ],
        patient_attributes: [
          :assigned_establishment_id
        ],
        close_contacts_attributes: [ 
          :id,
          :full_name,
          :dni,
          :phone,
          :sex,
          :address,
          :last_contact_date,
          :contact_type_id,
          :_destroy,
        ], 
      )
    end
    # Never trust parameters from the scary internet, only allow the white list through.
    def epidemic_sheet_params
      params.require(:epidemic_sheet).permit(
        :init_symptom_date, 
        :epidemic_week, 
        :presents_symptoms, 
        :symptoms_observations, 
        :present_previous_symptoms, 
        :prev_symptoms_observations,
        :clinic_location,
        symptom_ids: [],
        previous_symptom_ids: [],
        case_definition_attributes: [ 
          :id,
          :case_status_id,
          :special_device_id,
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
          :occupation_id,
          :assigned_establishment_id,
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
        ],
        close_contacts_attributes: [ 
          :id,
          :full_name,
          :dni,
          :phone,
          :sex,
          :address,
          :last_contact_date,
          :contact_type_id,
          :_destroy,
        ],
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
