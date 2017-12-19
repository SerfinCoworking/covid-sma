class PrescriptionsController < ApplicationController
  before_action :set_prescription, only: [:show, :edit, :update, :destroy]

  # GET /prescriptions
  # GET /prescriptions.json
  def index
    @prescriptions = Prescription.all
  end

  # GET /prescriptions/1
  # GET /prescriptions/1.json
  def show
  end

  # GET /prescriptions/new
  def new
    @prescription = Prescription.new
    @professionals = Professional.all
    @medications = Medication.all
    @patients = Patient.all
    @patient_types = PatientType.all
    @prescription.build_professional
    @prescription.build_patient
    @prescription.quantity_medications.build
    @prescription.quantity_supplies.build
  end

  # GET /prescriptions/1/edit
  def edit
    @professionals = Professional.all
    @medications = Medication.all
    @patients = Patient.all
    @patient_types = PatientType.all
  end

  # POST /prescriptions
  # POST /prescriptions.json
  def create
    @prescription = Prescription.new(prescription_params)
    if dispensing?
      @prescription.prescription_status = PrescriptionStatus.find_by_name("Dispensada")
      @prescription.date_dispensed = DateTime.now
    end
    @prescription.prescription_status = PrescriptionStatus.find_by_name("Pendiente") if loading?

    date_r = prescription_params[:date_received]
    @prescription.date_received = DateTime.strptime(date_r, '%d/%M/%Y %H:%M %p')

    respond_to do |format|
      if @prescription.save
        format.html { redirect_to @prescription, notice: 'La Prescripción se ha creado correctamente.' }
        format.json { render :show, status: :created, location: @prescription }
      else
        format.html { render :new }
        format.json { render json: @prescription.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /prescriptions/1
  # PATCH/PUT /prescriptions/1.json
  def update
    if dispensing?
      @prescription.prescription_status = PrescriptionStatus.find_by_name("Dispensada")
      @prescription.date_dispensed = DateTime.now
    end

    date = prescription_params[:date_received]
    @prescription.date_received = DateTime.strptime(date, '%d/%M/%Y %H:%M %p')

    respond_to do |format|
      if @prescription.update_attributes(prescription_params)
        format.html { redirect_to @prescription, notice: 'La Prescripción se ha modificado correctamente.' }
        format.json { render :show, status: :ok, location: @prescription }
      else
        format.html { render :edit }
        format.json { render json: @prescription.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /prescriptions/1
  # DELETE /prescriptions/1.json
  def destroy
    @prescription.destroy
    respond_to do |format|
      format.html { redirect_to prescriptions_url, notice: 'La Prescripción se ha eliminado correctamente.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_prescription
      @prescription = Prescription.find(params[:id])
    end

    def prescription_params
      params.require(:prescription).permit(:observation, :date_received, :professional_id, :patient_id, :prescription_status_id,
                                         quantity_medications_attributes: [:id, :medication_id, :quantity, :_destroy],
                                         quantity_supplies_attributes: [:id, :supply_id, :quantity, :_destroy],
                                         patient_attributes: [:id, :first_name, :last_name, :dni, :patient_type_id],
                                         professional_attributes: [:id, :first_name, :last_name, :dni])
    end

    def dispensing?
      submit = params[:commit]
      return submit == "Cargar y dispensar" || submit == "Guardar y dispensar"
    end

    def loading?
      params[:commit] == "Cargar prescripción"
    end
end
