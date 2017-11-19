require 'rake'
require 'rspec/core/rake_task'
require 'json'
require 'pathname'
require 'rainbow'
require 'rspec/core/rake_task'
require 'uri'
require 'rake'
require 'rspec/core/rake_task'

namespace :consul do 
  desc 'Run serverspec tests'
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = ['spec/consul/*_spec.rb','spec/shared/*_spec.rb']
  end


  desc 'Validate Templates'
  task :validate do
    Pathname.glob('consul/consul.json').sort.each do |template|
      puts Rainbow("Validating #{template}...").green
      unless system "packer validate #{template}"
        puts Rainbow("#{template} is not a valid packer template").red
        raise "#{template} is not a valid packer template"
      end
    end
  end

  desc 'Build Templates'
  task :build do
    Pathname.glob('consul/consul.json').sort.each do |template|
      unless system "packer build #{template}"
        puts Rainbow("#{template} build failed").red
        raise "#{template} built succesfully"
      end
    end
  end
end

namespace :nomad do
  desc 'Run serverspec tests'
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = ['spec/consul/*_spec.rb','spec/nomad/*_spec.rb','spec/shared/*_spec.rb']
  end


  desc 'Validate Templates'
  task :validate do
    Pathname.glob('nomad/nomad.json').sort.each do |template|
      puts Rainbow("Validating #{template}...").green
      unless system "packer validate #{template}"
        puts Rainbow("#{template} is not a valid packer template").red
        raise "#{template} is not a valid packer template"
      end
    end
  end

  desc 'Build Templates'
  task :build do
    Pathname.glob('nomad/nomad.json').sort.each do |template|
      unless system "packer build #{template}"
        puts Rainbow("#{template} build failed").red
        raise "#{template} built succesfully"
      end
    end
  end
end

namespace :vault do
  desc 'Run serverspec tests'
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = ['spec/consul/*_spec.rb','spec/shared/*_spec.rb','spec/vault/*_spec.rb']
  end


  desc 'Validate Templates'
  task :validate do
    Pathname.glob('vault/vault.json').sort.each do |template|
      puts Rainbow("Validating #{template}...").green
      unless system "packer validate #{template}"
        puts Rainbow("#{template} is not a valid packer template").red
        raise "#{template} is not a valid packer template"
      end
    end
  end

  desc 'Build Templates'
  task :build do
    Pathname.glob('vault/vault.json').sort.each do |template|
      unless system "packer build #{template}"
        puts Rainbow("#{template} build failed").red
        raise "#{template} built succesfully"
      end
    end
  end
end

namespace :hashistack do
  desc 'Run serverspec tests'
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = ['spec/consul/*_spec.rb','spec/nomad/*_spec.rb','spec/shared/*_spec.rb','spec/vault/*_spec.rb']
  end


  desc 'Validate Templates'
  task :validate do
    Pathname.glob('hashistack/hashistack.json').sort.each do |template|
      puts Rainbow("Validating #{template}...").green
      unless system "packer validate #{template}"
        puts Rainbow("#{template} is not a valid packer template").red
        raise "#{template} is not a valid packer template"
      end
    end
  end

  desc 'Build Templates'
  task :build do
    Pathname.glob('hashistack/hashistack.json').sort.each do |template|
      unless system "packer build #{template}"
        puts Rainbow("#{template} build failed").red
        raise "#{template} built succesfully"
      end
    end
  end
end
