
require 'active_record'
require 'fileutils'

CONFIG = {
  skeema_dir: ENV.fetch('SKEEMA_DIR', 'skeema'),
  source: {
    database: ENV.fetch('DB_NAME', 'smart_skeema_source'),
    adapter: 'mysql2',
    host: ENV.fetch('DB_HOST', 'sourcedb'),
    username: ENV.fetch('DB_USER', 'root'),
    password: ENV.fetch('DB_PASS', '') ,
  },
  target: {
    host: ENV.fetch('TARGET_DB_HOST', 'targetdb'),
    username: ENV.fetch('TARGET_DB_USER', 'root'),
    password: ENV.fetch('TARGET_DB_PASS', '') ,
  },
}.freeze

desc 'Try this thing out by using 2 empty dbs and a schema.rb file.'
task demo: [:populate, :reset_target_db, :read, :config, :diff, :apply, :cleanup] do
end

desc 'Populate the source database from the db/schema.rb file.'
task :populate do
  Rake::Task["reset_db"].invoke(CONFIG[:source].except(:database), CONFIG[:source][:database])
  ActiveRecord::Base.establish_connection(CONFIG[:source])
  ActiveRecord::Schema.load './db/schema.rb'
end

desc 'Use skeema to initialise from the source database. Creates .sql files in skeema dir.'
task :read do
  cmd = "skeema init -h #{CONFIG[:source][:host]} -u #{CONFIG[:source][:username]} -d #{CONFIG[:source][:database]} --schema #{CONFIG[:source][:database]} --dir #{CONFIG[:skeema_dir]}"
  cmd += "-p#{CONFIG[:source][:password]}" if CONFIG[:source][:password].length > 0

  system(cmd)
end

desc 'Configure the .skeema file to add the target environment and set alter-wrapper.'
task :config do

  cfg_file = "#{CONFIG[:skeema_dir]}/.skeema"
  cfg = IO.read(cfg_file)
  IO.write(cfg_file, 'alter-wrapper=/usr/bin/pt-online-schema-change --execute --alter-foreign-keys-method="auto" --alter {CLAUSES} D={SCHEMA},t={TABLE},h={HOST},P={PORT},u={USER},p={PASSWORDX}' + "\n" + cfg)

  cmd = "skeema add-environment target -h #{CONFIG[:target][:host]} -u #{CONFIG[:target][:username]} -d #{CONFIG[:source][:database]} --dir #{CONFIG[:skeema_dir]}"
  cmd += "-p#{CONFIG[:target][:password]}" if CONFIG[:target][:password].length > 0
  system(cmd)
end

desc 'Use skeema to display the differences between the source and and the target.'
task :diff do
  system("skeema diff --allow-unsafe target")
end

desc 'Use skeema to apply the changes required to make the target the same as the source.'
task :apply do
  system("skeema push --allow-unsafe target")
end

desc 'Remove the skeema dir.'
task :cleanup do
  FileUtils.rm_rf(CONFIG[:skeema_dir])
end

task :reset_db, [:config, :database] => [] do |_task, args|
  config = args.fetch(:config)
  database = args.fetch(:database)

  ActiveRecord::Base.establish_connection(config)

  begin
    ActiveRecord::Base.connection.drop_database(database)
  rescue Mysql2::Error
    # ignore, probs no db by the name to drop
  end

  ActiveRecord::Base.connection.create_database(database)
end

task :reset_target_db do
  config = CONFIG[:source].merge(CONFIG[:target]).except(:database)

  Rake::Task["reset_db"].invoke(config, CONFIG[:source][:database])
end
