require_relative 'site_base'

class AdditionalInformationPage < SiteBase
  page_title('Additional Action Required | Red Hat Developers')

  value(:feedback)                 { |el| el.text_of(css: '.warning') }

  element(:email_field)            { |el| el.find(id: 'email') }
  element(:email_field_error)      { |el| el.find(id: 'email-error')}
  element(:password_field)         { |el| el.find(id: 'user.attributes.pwd') }
  element(:confirm_password_field) { |el| el.find(id: 'password-confirm') }
  element(:first_name_field)       { |el| el.find(id: 'firstName') }
  element(:last_name_field)        { |el| el.find(id: 'lastName') }
  element(:company_field)          { |el| el.find(id: 'user.attributes.company') }
  element(:country_dropdown)       { |el| el.find(id: 'user.attributes.country') }

  action(:accept_all_terms)        { |el| el.click_on(id: 'tac-checkall') }
  action(:accept_tac1)             { |el| el.click_on(id: 'user.attributes.tcacc-6') }
  action(:accept_tac2)             { |el| el.click_on(id: 'user.attributes.tcacc-1246') }
  action(:click_submit)            { |el| el.click_on(xpath: "//input[@value='Submit']") }

  element(:error) { |el| el.text_of(css: '#kc-error-message .instruction') }
  action(:click_on_choose_another_email) { |el| el.click_on(id: 'updateProfile') }
  action(:click_send_verification_email) { |el| el.click_on(id: 'linkAccount') }

  def fill_in(email, password, first_name, last_name, company, country)
    wait_for {email_field.displayed? }
    email_field.send_keys(email)  unless email.nil?
    enter_password(password, password) unless password.nil?
    first_name_field.send_keys(first_name) unless first_name.nil?
    last_name_field.send_keys(last_name) unless last_name.nil?
    company_field.send_keys(company) unless company.nil?
    select_country(country) unless country.nil?
  end

  def enter_password(password, confirm_password)
    password_field.send_keys(password)
    confirm_password_field.send_keys(confirm_password)
  end

  def select_country(country)
    select(country_dropdown, country)
  end

  def fulluser_tac_accept
    accept_tac1
    accept_tac2
  end

  def accept_terms(term)
    case term
      when 'all'
        accept_all_terms.click
      when 'developer'
        accept_tac1.click
      when 'red hat'
        accept_tac2.click
      when 'portal'
        redhat_portal_terms.click
      else
        raise("#{term} is not a recognised condition")
    end
  end


end
