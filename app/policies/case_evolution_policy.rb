class CaseEvolutionPolicy < ApplicationPolicy
  def new?
    create?
  end

  def update?
    user.has_any_role?(:admin, :editar_evolucion)
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def delete?
    destroy?
  end
end
