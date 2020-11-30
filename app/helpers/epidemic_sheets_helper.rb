module EpidemicSheetsHelper
  def case_status_colors
    CaseStatus.all.map { |status| [status.name, map_color(status.badge)]}.to_h     
  end

  def map_color(bootstrap_color_string)
    if bootstrap_color_string == 'primary'
      return '#0275d8'
    elsif bootstrap_color_string == 'secondary'
      return '#6c757d'
    elsif bootstrap_color_string == 'success'
      return '#5cb85c'
    elsif bootstrap_color_string == 'danger'
      return '#d9534f'
    elsif bootstrap_color_string == 'warning'
      return '#f0ad4e'
    elsif bootstrap_color_string == 'info'
      return '#5bc0de'
    elsif bootstrap_color_string == 'light'
      return '#f7f7f7'
    elsif bootstrap_color_string == 'dark'
      return '#292b2c'
    end
  end
  
end
