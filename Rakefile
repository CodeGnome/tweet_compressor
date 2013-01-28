begin
  require 'bundler/gem_tasks' if Dir.glob('*gemspec').any?
  require 'bundler/setup'     if File.exists? 'Gemfile'
rescue LoadError => bundler_missing
  $stderr.puts bundler_missing
end

require 'rake'

PROJECT_NAME = File.basename(Dir.pwd).sub /\.rb$/, ''

desc 'Update exuberant-ctags'
task :etags do
  sh %{etags -R}
end

if Dir.exists? 'test'
  require 'rake/testtask'

  Rake::TestTask.new do |t|
      t.test_files = FileList[ 'test*' ]
  end
  task :default => :test
end

if Dir.exists? 'spec'
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task :default => :spec
end

desc 'Generate rdoc files'
task :rdoc do
  excludes = %w[AUTHORS LICENSE README* *gemspec]
  system "rdoc #{excludes.map { |file| "-x #{file}" }.join ' '}"
end

task :rename_objects do
  FileList['lib/**/**', 'README*', '.ruby-version', '.rvm'].each do |oldfile|
    next if File.directory? oldfile
    text = File.read(oldfile)

    next unless text.match /(require|module|class).*foo/i
    text.gsub!(/foo/i, PROJECT_NAME)
    File.open(oldfile, 'w') { |f| f.puts text }
  end
end

desc 'Rename lib files/objects'
task :rename => :rename_objects do
  libfiles = FileList['lib/**/**']
  libfiles.gsub(/foo/, PROJECT_NAME).zip(libfiles).each do |f|
    FileUtils.mv f[1], f[0] unless f.uniq.count == 1
  end
end
