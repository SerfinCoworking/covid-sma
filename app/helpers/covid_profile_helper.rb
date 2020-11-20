module CovidProfileHelper
  def label_covid_profile_status(a_profile)
    if a_profile.sospechoso?
      return 'light'
    elsif a_profile.pendiente?
      return 'warning'
    elsif a_profile.positivo?
      return 'danger'
    elsif a_profile.negativo?
      return 'primary'
    elsif a_profile.recuperado?
      return 'success'
    elsif a_profile.fallecido?
      return 'secondary'
    end
  end
end
