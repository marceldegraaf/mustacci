module Mustacci
  class Builder

    attr_reader :build_id

    def self.run!(build_id)
      new(build_id).run!
    end

    def initialize(build_id)
      @build_id = build_id
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
      @payload ||= Payload.load(build.payload_id)
    end

    def build
      @build ||= Mustacci::Build.load(build_id)
    end

    def log(message)
      $stderr.puts "\e[33m[#{now}] #{message}\e[0m"
    end

    def exe(command)
      log command
      system command
    end

    def exe!(command)
      exe command
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
      File.join(Mustacci.configuration.workspace, payload.repository.name)
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
      exe! "git clean -fdx"
      exe! "git fetch -q"
      exe! "git checkout -q #{sha}"

      if File.exist?(".mustacci")
        exe! "./.mustacci"
      elsif File.exist?("Gemfile")
        exe! "gem install bundler"
        exe! "bundle install"
        exe! "bundle exec rake"
      else
        exe! "rake"
      end
    end

    def create_success_note
      exe "git notes --ref=Mustacci add -fm 'Build successful! #{duration}' #{sha}"
      exe "git push -fq origin refs/notes/Mustacci"
    end

    def create_fail_note
      exe "git notes --ref=Mustacci add -fm 'Build failed! #{duration}' #{sha}"
      exe "git push -fq origin refs/notes/Mustacci"
    end

    def handle_failed_build(error)
      fatal error
      in_repo { create_fail_note }
    rescue BuildFailed => error
      fatal "Even handling failed build failed."
    ensure
      log "Running callbacks for failed builds"
      Mustacci.configuration.failed_callbacks.each { |cb| cb.call(build) }
      exit 1
    end

    def handle_success_build
      build.success!
      log "Running callbacks for successful builds"
      Mustacci.configuration.success_callbacks.each { |cb| cb.call(build) }
    end

    def fatal(message)
      $stderr.puts "\e[31m[#{now}] #{message}\e[0m"
    end

    def now
      Time.now
    end

    class BuildFailed < RuntimeError
    end

  end
end
