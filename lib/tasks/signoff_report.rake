namespace :signoffs do
  desc "Report members with partial class completions (have some signoffs from a class but not all)"
  task report: :environment do
    full      = ENV["FULL"] == "true"
    show_user = ENV["USER_ID"]

    classes = JSON.parse(File.read("app/assets/data/classes.json"))

    signoff_field = Field.signoffs
    abort "Could not find NL Signoffs and Categories field" unless signoff_field

    # Load all non-archived users with their signoff labels in one query
    signoff_labels_by_user = FieldUserValue
      .where(field: signoff_field)
      .joins(:field_allowed_value, :user)
      .merge(User.active_n_enabled)
      .then { |q| show_user ? q.where(user_id: show_user) : q }
      .pluck("users.id", "users.name", "field_allowed_values.label")
      .each_with_object({}) do |(uid, name, label), h|
        h[uid] ||= { name: name, signoffs: [] }
        h[uid][:signoffs] << label
      end

    report = []

    signoff_labels_by_user.each do |_uid, data|
      user_signoffs = data[:signoffs].to_set

      classes.each do |cls|
        required = cls["signoffs_granted"].to_set
        have     = user_signoffs & required
        missing  = required - user_signoffs

        next if have.empty?
        next if missing.empty? && !full

        report << {
          name:       data[:name],
          class_name: cls["class_name"],
          have:       have.to_a.sort,
          missing:    missing.to_a.sort,
          complete:   missing.empty?,
        }
      end
    end

    report.sort_by! { |r| [r[:name], r[:class_name]] }

    if report.empty?
      puts "No partial class completions found."
      next
    end

    partial_count = report.count { |r| !r[:complete] }
    full_count    = report.count { |r| r[:complete] }

    puts "=== Class Signoff Report ==="
    puts "#{partial_count} partial completions" + (full ? "  |  #{full_count} full completions" : "")
    puts

    report.group_by { |r| r[:name] }.each do |name, results|
      partials = results.reject { |r| r[:complete] }
      fulls    = results.select { |r| r[:complete] }

      puts name

      fulls.each { |r| puts "  ✓ #{r[:class_name]}" } if full

      partials.each do |r|
        have_count = r[:have].length
        need_count = have_count + r[:missing].length
        puts "  ~ #{r[:class_name]} (#{have_count}/#{need_count})"
        r[:have].each    { |s| puts "      ✓ #{s}" }
        r[:missing].each { |s| puts "      ✗ #{s}" }
      end

      puts
    end

    partials = report.reject { |r| r[:complete] }

    puts "=== Summary ==="
    puts "Members with partial completions: #{partials.map { |r| r[:name] }.uniq.length}"
    puts

    puts "By class:"
    partials.group_by { |r| r[:class_name] }
            .sort_by  { |_, rs| -rs.length }
            .each do |class_name, rs|
      puts "  #{rs.length.to_s.rjust(3)}  #{class_name}"
    end
    puts

    puts "Most commonly missing signoffs:"
    partials.flat_map { |r| r[:missing] }
            .tally
            .sort_by { |_, n| -n }
            .first(10)
            .each do |signoff, n|
      puts "  #{n.to_s.rjust(3)}  #{signoff}"
    end
  end
end
