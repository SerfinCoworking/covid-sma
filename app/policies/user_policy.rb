class UserPolicy < ApplicationPolicy

  def index?
    user.has_any_role?(:admin, :gestor_usuarios, :estadistica, :medico)
  end

  def update?
    record == user || user.has_any_role?(:admin, :gestor_usuarios)
  end

  def change_sector?
    record.sectors.count > 1 && self.update?
  end

  def edit_permissions?
    self.update?
  end

  def update_permissions?
    if ( record.has_role? :admin ) && ( record == user )
      return true
    elsif record.has_role? :admin
      return false
    else
      user.has_any_role?(:admin, :gestor_usuarios)
    end
  end

  def edit_permissions?
    self.update_permissions?
  end

  def show_establishment?
    user.has_any_role?(:admin)
  end
end
