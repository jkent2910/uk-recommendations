require "googleauth"
require "google_drive"

desc "build things from google sheet"
task build_things: :environment do
  spreadsheet_name = "uk_recommendations"

  ENV["GOOGLE_APPLICATION_CREDENTIALS"] = Rails.root.join("config", "google_creds.json").to_path

  credentials = Google::Auth.get_application_default
  credentials.scope = ["https://www.googleapis.com/auth/drive", "https://spreadsheets.google.com/feeds/"]
  credentials.fetch_access_token!
  access_token = credentials.access_token

  drive_session = GoogleDrive.login_with_oauth(access_token)

  spreadsheet = drive_session.spreadsheet_by_title(spreadsheet_name)
  raise "Spreadsheet #{spreadsheet_name} not found" unless spreadsheet
  worksheet = spreadsheet.worksheets.first

  attrs = worksheet.rows.first.map(&:to_sym)

  worksheet.rows.drop(1).each do |row|
    thing_attributes = attrs.zip(row).to_h
    thing = Thing.find_or_initialize_by(id: thing_attributes[:id])
    if thing.persisted?
      puts "Updating #{thing.what}"
    else
      puts "Adding #{thing_attributes[:what]}"
    end
    thing.update_attributes!(thing_attributes)
  end
end
