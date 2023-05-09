class User < ApplicationRecord
  has_one :credentials, dependent: :destroy # OAuth Credentials
  has_many :field_values, class_name: "FieldUserValue", dependent: :destroy
  has_many :event_registrations
  has_many :events, through: :event_registrations

  scope :search, ->(search_term) {
    like_term = "%#{search_term}%"

    # Use LIKE for SQLite, ILIKE for Postgres
    where(
      "email LIKE ? OR first_name LIKE ? OR last_name LIKE ?",
      like_term, like_term, like_term,
    )
  }

  scope :active_n_enabled, -> {
    where.not(membership_level_name: [nil, ""])
    .where(membership_enabled: true)
    .where(archived: false)
  }


  # {"provider"=>"wildapricot",
  #  "uid"=>"59100437",
  #  "info"=>{"email"=>"chris.sexton@nova-labs.org", "name"=>"Christopher Sexton"},
  #  "credentials"=>{"token"=>"4Vhf8e1NoRWTuv1oQcA9rV1U8Ko-", "refresh_token"=>"rt_2022-01-12_G74CM8qLVkHg5OF-nie1IxXa6Eg-", "expires_at"=>1642012132, "expires"=>true},
  #  "extra"=>
  #   {"raw_info"=>
  #     {"AdministrativeRoleTypes"=>["AccountAdministrator"],
  #      "FirstName"=>"Christopher",
  #      "LastName"=>"Sexton",
  #      "Email"=>"example@example.org",
  #      "DisplayName"=>"Sexton, Christopher",
  #      "MembershipLevel"=>
  #        {"Id"=>1264966,
  #         "Url"=>"https://api.wildapricot.org/v2/accounts/354313/MembershipLevels/1264966",
  #          "Name"=>"Key"},
  #      "Status"=>"Active",
  #      "Id"=>59100437,
  #      "Url"=>"https://api.wildapricot.org/v2/accounts/354313/Contacts/59100437",
  #      "IsAccountAdministrator"=>true,
  #      "TermsOfUseAccepted"=>true}}}
  def self.create_or_update_with_oauth(auth_hash)
    Rails.logger.info "Creating or updating user with #{auth_hash.to_json}"

    raise :unsupported unless auth_hash.provider == "wildapricot"

    user = User.find_or_create_by(provider: auth_hash.provider, uid: auth_hash.uid)
    user.email = auth_hash.info.email
    user.name = auth_hash.info.name
    user.url = auth_hash.extra.raw_info.Id
    if auth_hash.credentials
      user.credentials = Credentials.new()

      user.credentials.token = auth_hash.credentials.token
      user.credentials.refresh_token= auth_hash.credentials.refresh_token
      user.credentials.expires_at = auth_hash.credentials.expires_at
      user.credentials.expires = auth_hash.credentials.expires
    end

    user.save

    user
  end

  def signoffer?
    account_administrator? || admin || field_values.includes(:field_allowed_value).where(field_allowed_value: { label: "[NL] wautils" }).any?
  end

  # Returns a "truple" of user value, field, and allowed field models
  def signoffs
    #values = field_values.left_joins(:field, :field_allowed_value).where(field: Field.signoffs)
    values = field_values.signoffs

    values.map do |value|
      allowed = value.field.field_allowed_values.find_by(uid: value.value)
      [value, value.field, allowed]
    end
  end

  def signoff_values
    signoffs.map {|signoff_truple| signoff_truple.first.value }
  end

  def reason_for_free_access
    field_values.find_by(field:  Field.reason_for_free_access)&.label
  end

  def door_access_group
    field_values.find_by(field:  Field.door_access_group)&.label
  end

  def has_google_workspace_account?
    !!(email =~ /nova-labs.org$/ || secondary_email =~ /nova-labs.org$/)
  end

end
