# frozen_string_literal: true

class IntegromatWebhook
  def conn
    Faraday.new( headers: {'Content-Type' => 'application/json'})
  end

  def create_google_workspace_user(params)
    conn.post(ENV['INTEGROMAT_GOOGLE_WEBHOOK_URL']) do |req|
      req.body = params.to_json
    end
  end
end
