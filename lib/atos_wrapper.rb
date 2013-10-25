require 'rubygems'
# require 'bundler/setup'

require 'plist'
require 'open3'

class AtosWrapper

  class Error < ArgumentError; end;

  def initialize(app_path, options)
    unless File.directory?(app_path)
      raise Error, "Application bundle not found or is not a directory (#{app_path})"
    end

    dsym_path = "#{app_path}.dSYM"
    unless File.directory? dsym_path
      raise Error, "dSYM not found or is not a directory (#{dsym_path})"
    end

    app_info = File.join(app_path, 'Contents/Info.plist')
    app_info = Plist::parse_xml(app_info)

    app_exe = app_info['CFBundleExecutable']
    app_version = app_info['CFBundleShortVersionString']

    @app_exe_path = File.join(app_path, 'Contents/MacOS', app_exe)
    @app_bundle_id = app_info['CFBundleIdentifier']

    unless File.file? @app_exe_path
      raise Error, "Unable to find app executable: #{@app_exe_path}"
    end

    @arch = options[:arch]
    @arch ||= "x86_64"
    if @arch.strip.length == 0
      raise Error, "No architecture specified"
    end

    puts "Application: #{@app_bundle_id}, v#{app_version}"
    puts "Executable: #{@app_exe_path}"
  end

  def process(crashlog_path)
    unless File.file? crashlog_path
      puts "Error: crashlog file not found - #{crashlog_path}"
      return
    end

    addresses = []

    # parsing crashlog file.
    # 1. find the crashed thread
    # read stack trace from crashed thread
    crash_rx = /^Thread \d+ Crashed::/
    address_rx = /^\d+\s+(\S+)\s+(0x[[:xdigit:]]+)\s+(0x[[:xdigit:]]+)?/
    found_crashed_thread = false
    File.open(crashlog_path, "r") do |f|
      puts "\n\nProcessing crashlog #{crashlog_path}:\n"
      while line = f.gets
        unless found_crashed_thread
          # look for line starting Thread XX Crashed::
          if line.match crash_rx
            addresses << [nil, line]
            found_crashed_thread = true
          end
        else
          # look for stacktrace line
          matches = line.match(address_rx)
          if matches
            if matches[1] == @app_bundle_id && matches.length == 4
              # add [load_address, call_address], line
              addresses << [[matches[3], matches[2]], line]
            else
              addresses << [nil, line]
            end
          else
            # end of the Thread's crash
            break
          end
        end
      end
    end

    # symbolicate addresses
    addresses.map! do |address, line|
      unless address.nil?
        atos_cmd = "xcrun atos -arch #{@arch} -o #{@app_exe_path} -l #{address[0]} #{address[1]}"
        # address = `#{atos_cmd}`
        stdin, stdout, stderr = Open3.popen3(atos_cmd)
        address = stdout.read
      end
      [address, line]
    end

    # output the result
    addresses.each do |address, line|
      puts line
      puts address unless address.nil?
    end
  end
end