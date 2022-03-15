namespace :wa do
  def write_json_file(name, json)
    FileUtils.mkdir_p './tmp/wa-sync'
    #file_name = "./tmp/wa-sync/#{Time.zone.now.strftime('%Y%m%d-%H%M')}-#{name}.json"
    file_name = "./tmp/wa-sync/#{name}.json"
    File.write(file_name, JSON.pretty_generate(json))
    puts "   Saved response to #{file_name}"
  end

  desc "Sync Users from Wild Apricot"
  task :sync => [:environment, "wa:fields", "wa:users", "wa:events"]

  desc "Sync fields from Wild Apricot"
  task fields: :environment do
    sync = WildApricotSync.new

    puts "== Syncing fields =="
    contact_fields = WAAPI.contact_fields.json
    write_json_file(:contact_fields, contact_fields)
    puts "   Fields:"
    sync.contact_fields(contact_fields) do |field|
      puts "   #{field.id.to_s.rjust(4)} #{field.field_name}"
      unless field.allowed_values.empty?
        field.allowed_values.each do |v|
          puts "        - #{v.label}"
        end
      end
    end
  end

  desc "Sync users from Wild Apricot"
  task users: :environment do
    sync = WildApricotSync.new

    puts "== Syncing users =="
    contacts = WAAPI.contacts.json
    puts "   Users:"
    write_json_file(:contact, contacts)
    sync.contacts(contacts) do |contact|
      puts "   #{contact.id.to_s.rjust(4)} #{contact.name}"
    end
  end

  desc "Sync events from Wild Apricot"
  task events: :environment do
    sync = WildApricotSync.new

    puts "== Syncing events =="
    events = WAAPI.events.json
    write_json_file(:events, events)
    puts "   Events:"
    sync.events(events) do |event|
      puts "   #{event.id.to_s.rjust(4)} #{event.name}"
      event_registrations = WAAPI.event_registrations(event.uid).json
      write_json_file("event_registrations_#{event.uid}", event_registrations)
      sync.event_registrations(event, event_registrations) do |reg|
        puts "        - #{reg.display_name}"
      end
    end
  end
end
