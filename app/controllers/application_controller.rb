class ApplicationController < ActionController::Base
  before_action :notifiction_set_as_read, only: [:show]
  protect_from_forgery with: :exception
  before_action :authenticate_user!, :route_name, :keep_params
  #before_action :configure_permitted_parameters, if: :devise_controller?
  include Pundit
  
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render :text => exception, :status => 500
  end

  def user_not_authorized
    flash[:error] = "Usted no está autorizado para realizar esta acción."
    redirect_to(request.referrer || root_path)
  end
  protected
    
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_in) { |u| u.permit({ roles: [] }, :password, :password_confirmation, :username) }
    end
    
  private
    # Marcamos la notificacion comoo leida
    def notifiction_set_as_read
      if params[:notification_id].present?
        Notification.read!(params[:notification_id])
      end
    end

    def route_name
      Rails.application.routes.router.recognize(request) do |route, matches, param|
  
        if ((route.name.present? && !route.name.match(/factory_work/)) || !matches["controller".to_sym].match(/factory_works/))
          # puts "========================> INSIDE"
          # puts route.name
          # puts matches["controller".to_sym].match(/factory_works/)
          # puts "========================> DEBUG LINE"
          session[:orders] = []
        end
      end
    end
    
    # keep_params:
    # en este metodo se busca mantener los parametros de filtros y/o de paginacion
    # segun el controlador visitado.
    # El caso en que se debe aplicar es cuando se quiere mantener los filtros o paginacion aplicada de un listado
    # luego de haber realizado otra accion como lo es agregar / editar
    def keep_params
      # visita de cualquier ruta
      session[:my_url_controller] ||= ''    # inicializamos el la variable del controlador
      ignore_action = ["search_by_last_name", "search_by_first_name", "search_by_name"]   # definimos cuales acciones queremos ignorar
      
      # reiniciamos varaibels segun control:
      # si el controlador cambio (en cada request)
      # y si el request no se encuentra en la variable ignore_action
      if session[:my_url_controller] != params[:controller] && !ignore_action.include?(params[:action])
        session[:my_url_controller] = params[:controller]
        session[:filterrific] = nil
        session[:page] = nil
      elsif session[:my_url_controller] == params[:controller] && params[:action] == 'index'
        # en caso de que el controlador se el mismo, la unica accion que puede modificar tanto los filtros como el paginador es el index
        # entonces es aqui donde modificamos los valores mencionados
        
        # seteamos el valor de filterrific segun control:
        # si :filterrific esta presente en params
        # y si el mismo valor es diferente al que esta guardado en session
        if params[:filterrific].present? && (params[:filterrific] != session[:filterrific])
          session[:filterrific] = params[:filterrific]
          session[:page] = nil        # debemos tener en cuenta que si se filtra hay que reiniciar el valor de :page
        else
          # si no se aplico algun filtro:
          # solo pisamos el valor de :page, con su nuevo valor (si viene params[:page]) o con su valor de session
          session[:page] = params[:page].present? ? params[:page] : session[:page]
        end
      end
  
      # por ultimo igualamos los valores de params con los de session
      # igualamos el valor :filterrific de params con el de session
      params[:filterrific] = session[:filterrific]
      # igualamos el valor :page de params con el de session
      params[:page] = session[:page]
    end
  
end
