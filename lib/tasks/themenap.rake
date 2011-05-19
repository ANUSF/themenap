namespace :themenap do
  desc "Grab the theme from the configured server."
  task :grab => :environment do
    include Themenap
    nap
  end
end
