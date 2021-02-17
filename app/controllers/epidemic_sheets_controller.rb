class EpidemicSheetsController < ApplicationController
  before_action :set_epidemic_sheet, only: [:show, :edit, :update, :destroy, :delete, :set_in_sisa_modal, :set_in_sisa]
  before_action :set_epidemic_sheet_symptoms, only: [:new, :new_contact, :create, :edit, :update]

  def dashboard
    authorize EpidemicSheet
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
    authorize EpidemicSheet
    if params[:reset] == "true"
      params[:filterrific] = nil
    end

    @filterrific = initialize_filterrific(
      EpidemicSheet.by_city(current_user.establishment.city),
      params[:filterrific],
      select_options: {
        sorted_by: EpidemicSheet.options_for_sorted_by
      },
      persistence_id: false,
      default_filter_params: { sorted_by: 'notificacion_desc' },
    ) or return
    @epidemic_sheets = @filterrific.find.page(params[:page]).per_page(15)
    if request.format.xlsx?
      @epidemic_sheets = @filterrific.find
    end
    respond_to do |format|
      format.html
      format.js
      # format.xls { headers["Content-Disposition"] = "attachment; filename=\"FichasEpidemio_#{DateTime.now.strftime('%d/%m/%Y')}.xls\"" }
      format.xlsx { headers["Content-Disposition"] = "attachment; filename=\"FichasEpidemio_#{DateTime.now.strftime('%d/%m/%Y')}.xlsx\"" }
    end
  end

  # GET /epidemic_sheets/1
  # GET /epidemic_sheets/1.json
  def show
    authorize @epidemic_sheet
    respond_to do |format|
      format.html { render :show }
      format.json { render json: @epidemic_sheet }
    end
  end

  # GET /epidemic_sheets/new
  def new
    authorize EpidemicSheet
    @epidemic_sheet = EpidemicSheet.new
    @epidemic_sheet.build_case_definition
    @epidemic_sheet.build_patient
    @epidemic_sheet.patient.build_address
    @epidemic_sheet.patient.build_current_address
    @epidemic_sheet.patient.patient_phones.build
  end

  def new_contact
    authorize EpidemicSheet
    @epidemic_sheet = EpidemicSheet.new
    @epidemic_sheet.build_case_definition
    @epidemic_sheet.build_patient
    @epidemic_sheet.patient.build_address
    @epidemic_sheet.patient.build_current_address
    @epidemic_sheet.patient.patient_phones.build
    @origin_contact_patient = Patient.find(params[:parent_contact_id])
    @close_contact = CloseContact.find(params[:close_contact_id])
  end
  
  # GET /epidemic_sheets/1/edit
  def edit
    authorize @epidemic_sheet
  end

  # POST /epidemic_sheets
  # POST /epidemic_sheets.json
  def create
    @epidemic_sheet = EpidemicSheet.new(epidemic_sheet_params)
    @epidemic_sheet.created_by = current_user
    @epidemic_sheet.establishment = current_user.establishment
    authorize @epidemic_sheet
    @epidemic_sheet.patient.address_id = Address.update_or_create_address(patient_address_params[:patient_attributes], @epidemic_sheet.patient).id

    respond_to do |format|
      if @epidemic_sheet.save!
        EpidemicSheetMovement.create(user: current_user, epidemic_sheet: @epidemic_sheet, action: "creó", sector: current_user.sector)
        # actualizamos el "contact close" con el id del paciente que se acaba de crear, solo si se esta actualizando
        # los contactos de una ficha cargada.-
        if params[:epidemic_sheet][:locked_close_contact_id].present?
          @close_contact = CloseContact.find(params[:epidemic_sheet][:locked_close_contact_id])
          @close_contact.update(contact: @epidemic_sheet.patient)
          format.html { redirect_to @close_contact.patient.epidemic_sheet, notice: 'La ficha epidemiológica se ha modificado correctamente.' }
        end
        
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
    authorize @epidemic_sheet
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

  def epidemic_sheet_exists_modal
    # close_contact_id solo viene si se esta cargando una ficha para asociar a los contactos de otra ficha.
    if params[:close_contact_id].present?
      @close_contact = CloseContact.find(params[:close_contact_id])
    end
    
    @patient = Patient.search_dni(params[:contact_patient_dni]).first
    respond_to do |format|
      format.js
    end
  end
  
  def associate_epidemic_sheet
    # id de contacto (del contacto estrecho de la ficha padre)
    # id_paciente ( cuando se encuentra la ficha del contacto estrecho)
    # se debe buscar el close contact para poder asignarle el id del paciente real (el que encontro ficha id_paciente )
    @close_contact = CloseContact.find(params[:close_contact_patient])
    @patient = Patient.find(params[:id])
    @close_contact.update(contact: @patient)
    respond_to do |format|
      format.html { redirect_to @close_contact.patient.epidemic_sheet, notice: 'La ficha epidemiológica se ha modificado correctamente.' }
    end
  end
  
  # DELETE /epidemic_sheets/1
  # DELETE /epidemic_sheets/1.json
  def destroy
    authorize @epidemic_sheet
    @epidemic_sheet.destroy
    respond_to do |format|
      format.html { redirect_to epidemic_sheets_url, notice: 'La ficha epidemiológica se ha eliminado correctamente.' }
      format.json { head :no_content }
    end
  end
  
  # SET_IN_SISA_MODAL /epidemic_sheets/1
  # SET_IN_SISA_MODAL /epidemic_sheets/1.json
  def set_in_sisa_modal
    authorize @epidemic_sheet
    respond_to do |format|
      format.js { @epidemic_sheet }
    end
  end
  
  # SET_IN_SISA /epidemic_sheets/1
  # SET_IN_SISA /epidemic_sheets/1.json
  def set_in_sisa
    authorize @epidemic_sheet
    @epidemic_sheet.is_in_sisa = true
    @epidemic_sheet.save!
    respond_to do |format|
      format.html { redirect_to @epidemic_sheet, notice: 'Se ha marcado como cargado en SISA correctamente.' }
      format.json { render :show, status: :ok, location: @epidemic_sheet }
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
      @establishments = Establishment.by_city(current_user.establishment_city).sort_by &:name
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
        :notification_date,
        symptom_ids: [],
        previous_symptom_ids: [],
        case_definition_attributes: [ 
          :id,
          :case_status_id,
          :special_device_id,
          :diagnostic_method_id
        ],
        patient_attributes: [
          :assigned_establishment_id,
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
          :contact_id
        ], 
      )
    end
    # Never trust parameters from the scary internet, only allow the white list through.
    def epidemic_sheet_params
      params.require(:epidemic_sheet).permit(
        :parent_contact_id,
        :locked_close_contact_id,
        :init_symptom_date,
        :epidemic_week,
        :presents_symptoms,
        :symptoms_observations,
        :present_previous_symptoms,
        :prev_symptoms_observations,
        :clinic_location,
        :notification_date,
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
          :contact_id
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
