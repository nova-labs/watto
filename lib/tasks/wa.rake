namespace :wa do
  desc "Sync Users from Wild Apricot"
  task :sync => [:environment, "wa:fields", "wa:users", "wa:events"]

  desc "Sync fields from Wild Apricot"
  task fields: :environment do
    sync = WildApricotSync.new

    puts "Syncing fields..."
    contact_fields = WAAPI.contact_fields.json
    sync.contact_fields(contact_fields) do |field|
      puts "   #{field.id} #{field.field_name}"
      unless field.allowed_values.empty?
        field.allowed_values.each do |v|
          puts "        #{v.label}"
        end
      end
    end
  end

  desc "Sync fields from Wild Apricot"
  task users: :environment do
    sync = WildApricotSync.new

    puts "Syncing users..."
    contacts = WAAPI.contacts.json
    sync.contacts(contacts) do |contact|
      puts "   #{contact.id} #{contact.name}"
    end
  end

  desc "Sync Events from Wild Apricot"
  task events: :environment do
    sync = WildApricotSync.new

    puts "Syncing events..."
    events = WAAPI.events.json
    sync.events(events) do |event|
      puts "   #{event.id} #{event.name}"

      sync.event_registrations(event, WAAPI.event_registrations(event.uid).json) do |reg|
        puts "     #{reg.id} #{reg.display_name}"
      end
    end
  end
end
