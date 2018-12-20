class InternalOrdersController < ApplicationController
  before_action :set_internal_order, only: [:show, :edit, :update, :destroy, :delete, 
  :edit_applicant, :send_provider, :receive_applicant_confirm, :receive_applicant, 
  :return_provider_status, :return_applicant_status,:send_applicant ]

  # GET /internal_orders
  # GET /internal_orders.json
  def index
    authorize InternalOrder
    @filterrific = initialize_filterrific(
      InternalOrder.provider(current_user.sector),
      params[:filterrific],
      select_options: {
        with_status: InternalOrder.options_for_status
      },
      persistence_id: false,
      default_filter_params: {sorted_by: 'created_at_desc'},
      available_filters: [
        :search_applicant,
        :search_supply_code,
        :search_supply_name,
        :with_status,
        :requested_date_at,
        :received_date_at,
        :sorted_by
      ],
    ) or return
    @internal_orders = @filterrific.find.page(params[:page]).per_page(15)
  end
  
  # GET /internal_orders
  # GET /internal_orders.json
  def applicant_index
    authorize InternalOrder
    @filterrific = initialize_filterrific(
      InternalOrder.applicant(current_user.sector),
      params[:filterrific],
      select_options: {
        with_status: InternalOrder.options_for_status
      },
      persistence_id: false,
      default_filter_params: {sorted_by: 'created_at_desc'},
      available_filters: [
        :search_applicant,
        :search_provider,
        :search_supply_code,
        :search_supply_name,
        :with_status,
        :requested_date_at,
        :received_date_at,
        :sorted_by
      ],
    ) or return
    @applicant_orders = @filterrific.find.page(params[:page]).per_page(15)

    respond_to do |format|
      format.html
      format.js
      format.pdf do
        send_data generate_apply_report(@applicant_orders),
          filename: 'pedidos_internos.pdf',
          type: 'application/pdf',
          disposition: 'inline'
      end
    end
  end

  # GET /internal_orders/1
  # GET /internal_orders/1.json
  def show
    authorize @internal_order
  end

  # GET /internal_orders/new
  def new
    authorize InternalOrder
    @internal_order = InternalOrder.new
    @providers = User.where.not(sector: current_user.sector_id )

    @internal_order.ord_quantity_supply_lots.build
  end

  # GET /internal_orders/new_deliver
  def new_provider
    authorize InternalOrder
    @internal_order = InternalOrder.new
    @order_type = 'provision'
    @applicant_sectors = Sector
      .select(:id, :name)
      .with_establishment_id(current_user.sector.establishment_id)
      .where.not(id: current_user.sector_id).as_json
    5.times { @internal_order.quantity_ord_supply_lots.build }
  end

  # GET /internal_orders/new_applicant
  def new_applicant
    authorize InternalOrder
    @internal_order = InternalOrder.new
    @order_type = 'solicitud'
    @provider_sectors = Sector
      .select(:id, :name)
      .with_establishment_id(current_user.sector.establishment_id)
      .where.not(id: current_user.sector_id).as_json
    5.times { @internal_order.quantity_ord_supply_lots.build }
  end

  # GET /internal_orders/1/edit
  def edit
    authorize @internal_order
    @order_type = 'provision'
    @applicant_sectors = Sector
    .select(:id, :name)
    .with_establishment_id(current_user.sector.establishment_id)
    .where.not(id: current_user.sector_id).as_json
  end

  # GET /ordering_supplies/1/edit_receipt
  def edit_applicant
    authorize @internal_order
    @order_type = 'solicitud'
    @provider_sectors = Sector
      .select(:id, :name)
      .with_establishment_id(current_user.sector.establishment_id)
      .where.not(id: current_user.sector_id).as_json
  end

  # POST /internal_orders
  # POST /internal_orders.json
  def create
    @internal_order = InternalOrder.new(internal_order_params)
    authorize @internal_order
    @internal_order.created_by = current_user
    @internal_order.audited_by = current_user

    respond_to do |format|
      if @internal_order.save
        begin
          if @internal_order.provision?
            # Si se carga y provision el pedido
            if sending?
              @internal_order.send
              @internal_order.create_notification(current_user, "creó y envió")
              flash[:success] = "La provisión interna de "+@internal_order.applicant_sector.name+" se ha auditado y enviado correctamente."
            else
              @internal_order.proveedor_auditoria!
              @internal_order.create_notification(current_user, "creó y auditó")
              flash[:success] = "La provisión interna de "+@internal_order.applicant_sector.name+" se ha auditado correctamente."
            end
          elsif @internal_order.solicitud?
            if sending?
              @internal_order.solicitud_enviada!
              @internal_order.create_notification(current_user, "creó y envió")
              flash[:success] = "La solicitud se ha auditado y enviado correctamente."
            else
              @internal_order.solicitud_auditoria!
              @internal_order.create_notification(current_user, "creó y auditó")
              flash[:success] = "La solicitud se ha creado y se encuentra en auditoria."
            end
          end
        rescue ArgumentError => e
          flash[:alert] = e.message
        end
        format.html { redirect_to @internal_order }
      else
        5.times { @internal_order.quantity_ord_supply_lots.build }
        if @internal_order.provision?
          @order_type = 'provision'
          @applicant_sectors = Sector
          .select(:id, :name)
          .with_establishment_id(current_user.sector.establishment_id)
          .where.not(id: current_user.sector_id).as_json
          
          flash[:error] = "La provision no se ha podido crear."
          format.html { render :new_provider }
        elsif @internal_order.solicitud?
          @order_type = 'solicitud'
          @provider_sectors = Sector
          .select(:id, :name)
          .with_establishment_id(current_user.sector.establishment_id)
          .where.not(id: current_user.sector_id).as_json
          
          flash[:error] = "La solicitud no se ha podido crear."
          format.html { render :new_applicant }
        end
      end
    end
  end

  # PATCH/PUT /internal_orders/1
  # PATCH/PUT /internal_orders/1.json
  def update
    authorize @internal_order
    @user_id = internal_order_params.extract!(:sent_by_id)
    audited_by = current_user
    respond_to do |format|
      begin
        if @internal_order.update(internal_order_params)
            if @internal_order.provision?
              if sending_by_provider?
                @internal_order.send_order_by_user_id(@user_id)
                @internal_order.create_notification(current_user, "auditó y envió")
                flash[:success] = 'La provision se ha enviado correctamente.'
              else
                @internal_order.create_notification(current_user, "auditó")
                flash[:notice] = 'La provision se ha auditado correctamente.'
              end
            elsif @internal_order.solicitud?
              if sending?
                @internal_order.send_request_of(current_user)
                @internal_order.create_notification(current_user, "auditó y envió")
                flash[:success] = 'La solicitud se ha enviado correctamente.'
              elsif sending_by_provider?
                @internal_order.send_order_by_user_id(@user_id)
                @internal_order.create_notification(current_user, "envió")
                flash[:success] = 'La solicitud se ha provisto correctamente.'
              elsif applicant?
                @internal_order.solicitud_auditoria!
                @internal_order.create_notification(current_user, "auditó")
                flash[:notice] = 'La solicitud se ha auditado correctamente.'
              elsif provider?
                @internal_order.proveedor_auditoria!
                @internal_order.create_notification(current_user, "auditó")
                flash[:notice] = 'La solicitud se ha auditado correctamente.'
              end
            end
          format.html { redirect_to @internal_order }
        else
          @sectors = Sector.with_establishment_id(@internal_order.applicant_sector.establishment_id)
          format.html { render :edit }
          format.json { render json: @internal_order.errors, status: :unprocessable_entity }
        end
      rescue ArgumentError => e
        flash[:alert] = e.message
      end 
      format.html { redirect_to @internal_order }
    end
  end

  # DELETE /internal_orders/1
  # DELETE /internal_orders/1.json
  def destroy
    authorize @internal_order

    @internal_order.destroy
    respond_to do |format|
      @internal_order.create_notification(current_user, "envió a la papelera")
      flash.now[:success] = "El pedido interno de se ha enviado a la papelera correctamente."
      format.js
    end
  end

  # GET /internal_order/1/delete
  def delete
    authorize @internal_order
    respond_to do |format|
      format.js
    end
  end

  # GET /internal_order/1/send_provider
  def send_provider
    authorize @internal_order
    @users = User.with_sector_id(current_user.sector_id)
    respond_to do |format|
      format.js
    end
  end

  # GET /internal_orders/1/send_applicant
  def send_applicant
    authorize @internal_order
    @internal_order.solicitud_enviada!
    respond_to do |format|
      flash[:success] = "La solicitud se ha enviado correctamente."
      format.html { redirect_to @internal_order }
    end
  end

  # GET /internal_orders/1/receive_applicant
  def receive_applicant
    authorize @internal_order
    respond_to do |format|
      begin
        @internal_order.received_by = current_user
        @internal_order.receive_order(current_user.sector)
        @internal_order.create_notification(current_user, "recibió")
        flash[:success] = 'La '+@internal_order.order_type+' se ha recibido correctamente'
      rescue ArgumentError => e
        flash[:error] = e.message
      end
      format.html { redirect_to @internal_order }
    end
  end

  # GET /internal_orders/1/receive_applicant_confirm
  def receive_applicant_confirm
    respond_to do |format|
      format.js
    end
  end

  def return_provider_status
    authorize @internal_order
    respond_to do |format|
      begin
        @internal_order.return_provider_status
        @internal_order.create_notification(current_user, "retornó a un estado anterior")
        flash[:notice] = 'La '+@internal_order.order_type+' se ha retornado a un estado anterior.'
      rescue ArgumentError => e
        flash[:alert] = e.message
      end
      format.html { redirect_to @internal_order }
    end
  end

  def return_applicant_status
    authorize @internal_order
    respond_to do |format|
      begin
        @internal_order.return_applicant_status
        @internal_order.create_notification(current_user, "retornó a un estado anterior")
        flash[:notice] = 'La solicitud se ha retornado a un estado anterior.'
      rescue ArgumentError => e
        flash[:alert] = e.message
      end
      format.html { redirect_to @internal_order }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_internal_order
      @internal_order = InternalOrder.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def internal_order_params
      params.require(:internal_order).permit(:applicant_sector_id, :sent_by_id, :order_type,
        :provider_sector_id, :requested_date, :date_received, :observation, :remit_code,
        quantity_ord_supply_lots_attributes: [:id, :supply_id, :sector_supply_lot_id,
          :requested_quantity, :delivered_quantity, :observation, :applicant_observation,
          :provider_observation, :_destroy]
        )
    end

    # Se verifica si el value del submit del form es para enviar
    def sending?
      submit = params[:commit]
      return submit == "Auditar y enviar" || submit == "Enviar"
    end

    def sending_by_provider?
      submit = params[:commit]
      return submit == "Enviar proveedor"
    end

    def applicant?
      submit = params[:commit]
      return submit == "Solicitante"
    end

    def provider?
      submit = params[:commit]
      return submit == "Proveedor"
    end

    def generate_apply_report(orders)
      report = Thinreports::Report.new layout: File.join(Rails.root, 'app', 'reports', 'internal_order', 'i_o_list.tlf')

      orders.each do |order|
        report.list.add_row do |row|
          row.values  code: order.remit_code,
                      sector_name: order.provider_sector.name,
                      origin: order.order_type.underscore.humanize,
                      status: order.status.underscore.humanize,
                      supplies: order.quantity_ord_supply_lots.count,
                      movements: order.movements.count,
                      requested_date: order.requested_date.strftime("%d/%m/%Y"),
                      received_date: order.date_received.present? ? order.date_received.strftime("%d/%m/%Y") : '----'
        end
      end
      report.page[:page_count] = report.page_count
      report.page[:title] = 'Reporte recibos pedidos internos'

      report.generate
    end
end
