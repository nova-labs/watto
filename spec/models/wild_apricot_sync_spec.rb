# frozen_string_literal: true
require 'rails_helper'

RSpec.describe WildApricotSync do
  it "does not create duplicate records when syncing contact_fields" do
    json = json_file_fixture('waapi_contact_fields.json')

    sync = WildApricotSync.new
    sync.contact_fields(json)
    expect(FieldAllowedValue.count).to eq 102
    expect(Field.count).to eq 47

    sync.contact_fields(json)
    expect(FieldAllowedValue.count).to eq 102
    expect(Field.count).to eq 47
  end

  context "with fields loaded" do
    before :all do
      WildApricotSync.new.contact_fields(json_file_fixture('waapi_contact_fields.json'))
    end

    it "deletes field values when they are missing from the AllowedValues array" do
      json = [{
        "Url"=>"https://api.wildapricot.org/v2.2/accounts/354313/ContactFields/12971567",
        "Id"=>12971567,
        "Access"=>"Nobody",
        "MemberAccess"=>"ViewOnly",
        "MemberOnly"=>true,
        "IsBuiltIn"=>false,
        "SupportSearch"=>true,
        "IsEditable"=>true,
        "AdminOnly"=>false,
        "FieldType"=>"MultipleChoice",
        "FieldName"=>"NL Signoffs and Categories",
        "Type"=>"MultipleChoice",
        "AllowedValues"=> [
          {"Id"=>14759088, "Label"=>"[equipment] 3D_FDM Printers", "Value"=>"14759088", "SelectedByDefault"=>false, "Position"=>0},
          {"Id"=>14759089, "Label"=>"[equipment] 3D_HP_3D Scanner", "Value"=>"14759089", "SelectedByDefault"=>false, "Position"=>1},
          {"Id"=>14759090, "Label"=>"[equipment] 3d_Phrozen_LCD SLA", "Value"=>"14759090", "SelectedByDefault"=>false, "Position"=>2},
          {"Id"=>14759091, "Label"=>"[equipment] AC_APW_Heat Press", "Value"=>"14759091", "SelectedByDefault"=>false, "Position"=>3},
        ],
        "IsSystem"=>false,
        "FieldInstructions"=>"",
        "Order"=>9,
        "DisplayType"=>"CheckboxGroup",
        "SystemCode"=>"custom-12971567",
        "IsRequired"=>false
      }]


      sync = WildApricotSync.new
      sync.contact_fields(json)
      expect(json.first["AllowedValues"].length).to eq 4
      expect(Field.find_by(uid:12971567).field_allowed_values.count).to eq 4

      json.first["AllowedValues"].pop

      sync2 = WildApricotSync.new
      sync2.contact_fields(json)
      expect(json.first["AllowedValues"].length).to eq 3
      expect(Field.find_by(uid:12971567).field_allowed_values.count).to eq 3

    end

    it "does not create duplicate records when syncing contacts" do
      json = json_file_fixture('waapi_contacts.json')
      sync = WildApricotSync.new
      sync.contacts(json)
      expect(User.count).to eq 3

      sync.contacts(json)
    end

    it "creates user field association" do
      json = json_file_fixture('waapi_contacts.json')
      sync = WildApricotSync.new
      sync.contacts(json)
      expect(User.count).to eq 3

      sync.contacts(json)
    end

    it "removes admin flag when the [nlgroup] wautils is removed" do
      json = json_file_fixture('waapi_contact_59100437.json')

      sync = WildApricotSync.new
      sync.contact(json)
      user = User.find_by uid: 59100437
      expect(user.admin).to eq true

      # Remove all signoffs, including the `wautils` one
      idx = json["FieldValues"].find_index {|field| field["FieldName"] == "NL Signoffs and Categories" }
      json["FieldValues"].delete_at(43)

      sync.contact(json)
      user = user.reload
      expect(user.admin).to eq false
    end
  end
end
