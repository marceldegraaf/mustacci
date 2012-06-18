require 'mustacci/payload'

module Mustacci
  class Runner

    attr_reader :filename

    def self.run!(filename)
      new(filename).run!
    end

    def initialize(filename)
      @filename = filename
    end

    def run!
      clone_repository
      in_repo do
        time { run_build }
        create_success_note
      end
      handle_success_build
    rescue BuildFailed => error
      handle_failed_build error
    end

    def payload
      @payload ||= Payload.load(filename)
    end

    def log(message)
      $stderr.puts "\e[33m[#{now}] #{message}\e[0m"
    end

    def exe(command)
      log command
      system command
      raise BuildFailed, "Command failed: #{command.inspect}" if $?.to_i != 0
    end

    def in_repo
      Dir.chdir path do
        yield
      end
    end

    def time
      start = now
      yield
    ensure
      @duration = now - start
    end

    def duration
      duration = "%.3f seconds" % @duration
      "(#{now}, duration: #{duration})"
    end

    def path
      "tmp/workspace/#{payload.repository.name}"
    end

    def sha
      payload.after
    end

    def url
      payload.repository.url
    end

    def clone_repository
      exe "git clone #{url} #{path}" unless File.exist?(path)
    end

    def run_build
      exe "git clean -fdx"
      exe "git fetch"
      exe "git checkout -q #{sha}"

      if File.exist?(".mustacci")
        exe "./.mustacci"
      elsif File.exist?("Gemfile")
        exe "gem install bundler"
        exe "bundle install"
        exe "bundle exec rake"
      else
        exe "rake"
      end
    end

    def create_success_note
      exe "git notes --ref=Mustacci add -fm 'Build successful! #{duration}' #{sha}"
      exe "git push origin refs/notes/Mustacci"
    end

    def create_fail_note
      exe "git notes --ref=Mustacci add -fm 'Build failed! #{duration}' #{sha}"
      exe "git push -f origin refs/notes/Mustacci"
    end

    def handle_failed_build(error)
      $stderr.puts "\e[31m#{error}\e[0m"
      in_repo { create_fail_note }
    rescue BuildFailed => error
      $stderr.puts "\e[31mEven handling failed build failed.\e[0m"
    ensure
      exe "./script/failed #{ARGV.join(" ")}"
      exit 1
    end

    def handle_success_build
      exe "./script/success #{filename}"
    end

    def now
      Time.now
    end

    class BuildFailed < RuntimeError
    end

  end
end
