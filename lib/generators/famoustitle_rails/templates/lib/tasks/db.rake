namespace :db do

  desc "drop/create/migrate/seed"
  task :clean => :environment do
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:seed'].invoke
    puts "DB re-created, migrated, and seeded!"
  end

end
