PROJECT_NAME = "NoChat"
EXECUTABLE_NAME = PROJECT_NAME
SPECS_TARGET_NAME = "Specs"
UI_SPECS_TARGET_NAME = "UISpecs"
SDK_VERSION = "6.1"
PROJECT_ROOT = File.dirname(__FILE__)
BUILD_DIR = File.join(PROJECT_ROOT, "build")
TESTFLIGHT_API_TOKEN = ENV['TESTFLIGHT_API_TOKEN']
TESTFLIGHT_TEAM_TOKENS = { :staging => ENV['TESTFLIGHT_STAGING_TEAM_TOKEN'],
                           :production => ENV['TESTFLIGHT_PRODUCTION_TEAM_TOKEN'] }
TESTFLIGHT_DISTRIBUTION_LISTS = { :staging => "InnerCircle", :production => "NoChatTeam" }
TRACKER_ID = "1040020"

# Xcode 4.3 stores its /Developer inside /Applications/Xcode.app, Xcode 4.2 stored it in /Developer
def xcode_developer_dir
  `xcode-select -print-path`.strip
end

def sdk_dir
  "#{xcode_developer_dir}/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator#{SDK_VERSION}.sdk"
end

def configuration_build_dir(effective_platform_name)
  File.join(BUILD_DIR, build_configuration + effective_platform_name)
end

def system_or_exit(cmd, stdout = nil)
  puts "Executing #{cmd}"
  cmd += " >#{stdout}" if stdout
  system(cmd) or raise "******** Build failed ********"
end

def output_file(target)
  output_dir = if ENV['IS_CI_BOX']
    ENV['CC_BUILD_ARTIFACTS']
  else
    Dir.mkdir(BUILD_DIR) unless File.exists?(BUILD_DIR)
    BUILD_DIR
  end

  output_file = File.join(output_dir, "#{target}.output")
  puts "Output: #{output_file}"
  output_file
end

def target_server
  production_build? ? :production : :staging
end

def build_configuration
  production_build? ? "ProductionRelease" : "Release"
end

def production_build?
  ENV["PRODUCTION"]
end

task :default => [:trim_whitespace, :specs, :uispecs]
task :cruise do
  Rake::Task[:clean].invoke
#  Rake::Task[:build_all].invoke
  Rake::Task[:specs].invoke
  Rake::Task[:uispecs].invoke
end

task :trim_whitespace do
  system_or_exit(%Q[git status --short | awk '{if ($1 != "D" && $1 != "R") print $2}' | grep -e '.*\.[mh]$' | xargs sed -i '' -e 's/	/    /g;s/ *$//g;'])
end

task :clean do #TODO
  system_or_exit(%Q[xcodebuild -project #{PROJECT_NAME}.xcodeproj -alltargets -configuration #{build_configuration} clean SYMROOT=#{BUILD_DIR}], output_file("clean"))
end

task :build_specs do
  system_or_exit(%Q[xcodebuild -workspace #{PROJECT_NAME}.xcworkspace -scheme #{SPECS_TARGET_NAME} -configuration #{build_configuration} build CONFIGURATION_BUILD_DIR=#{configuration_build_dir("")} SYMROOT=#{BUILD_DIR}], output_file("specs"))
end

task :build_uispecs do
  `osascript -e 'tell application "iPhone Simulator" to quit'`
  system_or_exit(%Q[xcodebuild -workspace #{PROJECT_NAME}.xcworkspace -scheme #{UI_SPECS_TARGET_NAME} -configuration #{build_configuration} -sdk iphonesimulator ARCHS=i386 build CONFIGURATION_BUILD_DIR=#{configuration_build_dir("-iphonesimulator")} SYMROOT=#{BUILD_DIR}], output_file("uispecs"))
end

task :build_all do #TODO
  system_or_exit(%Q[xcodebuild -workspace #{PROJECT_NAME}.xcworkspace -alltargets -configuration #{build_configuration} build CONFIGURATION_BUILD_DIR=#{configuration_build_dir} SYMROOT=#{BUILD_DIR}], output_file("build_all"))
end

task :specs => :build_specs do
  build_dir = configuration_build_dir("")
  ENV["DYLD_FRAMEWORK_PATH"] = build_dir
  ENV["CEDAR_REPORTER_CLASS"] = "CDRColorizedReporter"
  system_or_exit(File.join(build_dir, SPECS_TARGET_NAME))
end

require 'tmpdir'
task :uispecs => :build_uispecs do
  ENV["DYLD_ROOT_PATH"] = sdk_dir
  ENV["IPHONE_SIMULATOR_ROOT"] = sdk_dir
  ENV["CFFIXED_USER_HOME"] = Dir.tmpdir
  ENV["CEDAR_HEADLESS_SPECS"] = "1"
  ENV["CEDAR_REPORTER_CLASS"] = "CDRColorizedReporter"

  system_or_exit(%Q[#{File.join(configuration_build_dir("-iphonesimulator"), "#{UI_SPECS_TARGET_NAME}.app", UI_SPECS_TARGET_NAME)} -RegisterForSystemEvents]);
end

task :build_for_device do
  if `git status --short`.length != 0
    raise "******** Cannot push with uncommitted changes ********"
  end

  system_or_exit("agvtool next-version -all")
  build_number = `agvtool what-version -terse`.chomp

  system_or_exit("git commit -am'Updated build number to #{build_number}'")
  system_or_exit(%Q[xcodebuild -workspace #{PROJECT_NAME}.xcworkspace -scheme #{PROJECT_NAME} -configuration #{build_configuration} -sdk iphoneos ARCHS=armv7 build CONFIGURATION_BUILD_DIR=#{configuration_build_dir("-iphoneos")} SYMROOT=#{BUILD_DIR}], output_file("build_for_device"))
  system_or_exit("git push origin master")
end

task :archive => :build_for_device do
  system_or_exit(%Q[xcrun -sdk iphoneos PackageApplication #{BUILD_DIR}/#{build_configuration}-iphoneos/#{EXECUTABLE_NAME}.app -o #{BUILD_DIR}/#{build_configuration}-iphoneos/#{EXECUTABLE_NAME}.ipa])
end

task :archive_dsym_file do 
    system_or_exit(%Q[zip -r #{BUILD_DIR}/#{build_configuration}-iphoneos/#{EXECUTABLE_NAME}.app.dSYM.zip #{BUILD_DIR}/#{build_configuration}-iphoneos/#{EXECUTABLE_NAME}.app.dSYM], output_file("build_all"))
end

namespace :testflight do
  task :deploy => [:archive, :archive_dsym_file] do

    file      = "#{BUILD_DIR}/#{build_configuration}-iphoneos/#{EXECUTABLE_NAME}.ipa"
    notes     = "Please refer to Tracker (https://www.pivotaltracker.com/projects/#{TRACKER_ID}) for further information about this build"
    dysmzip   = "#{BUILD_DIR}/#{build_configuration}-iphoneos/#{EXECUTABLE_NAME}.app.dSYM.zip"

    system_or_exit(%Q[curl http://testflightapp.com/api/builds.json -F file=@#{file} -F dsym=@#{dysmzip} -F api_token=#{TESTFLIGHT_API_TOKEN} -F team_token="#{TESTFLIGHT_TEAM_TOKENS[target_server]}" -F notes="#{notes}" -F notify=True -F distribution_lists="#{TESTFLIGHT_DISTRIBUTION_LISTS[target_server]}"])
  end
end

