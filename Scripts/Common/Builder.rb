require_relative "Tool.rb"
require_relative "Lib.rb"
require_relative "Arch.rb"
require_relative "Config.rb"
require_relative "Location.rb"
require_relative "Downloader.rb"

class Builder < Tool

   attr_reader :builds, :installs, :sources

   def initialize(component, arch)
      @component = component
      @arch = arch
      @sources = "#{Config.sources}/#{component}"
      @patches = "#{Config.patches}/#{component}"
      @builds = "#{Config.build}/#{arch}/#{component}"
      @installs = "#{Config.install}/#{arch}/#{component}"
      @startSpacer = ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
      @endSpacer =   "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
      @dryRun = ENV['SA_DRY_RUN'].to_s.empty? == false
   end

   def lib
      return @installs + "/lib"
   end

   def bin
      return @installs + "/bin"
   end

   def include
      return @installs + "/include"
   end

   def usr
      return @installs + "/usr"
   end

   # ------------------------------------

   def logStarted(action)
      puts ""
      print(@startSpacer, 33)
      print("\"#{@component}\" #{action} is started.", 36)
   end

   def logCompleted(action)
      print("\"#{@component}\" #{action} is completed.", 36)
      print(@endSpacer, 33)
      puts ""
   end

   def logConfigureStarted
      logStarted("Configure")
   end

   def logBuildStarted
      logStarted("Build")
   end

   def logInstallStarted
      logStarted("Install")
   end

   def logSetupCompleted
      logCompleted("Setup")
   end

   def logBuildCompleted
      logCompleted("Build")
   end

   def logConfigureCompleted
      logCompleted("Configure")
   end

   def logInstallCompleted
      logCompleted("Install")
   end

   # ------------------------------------

   def removeInstalls()
      execute "rm -rf \"#{@installs}\""
   end

   def removeBuilds()
      execute "rm -rf \"#{@builds}\""
   end

   def prepareBuilds()
      execute "mkdir -p \"#{@builds}\""
   end

   def setupLinkerSymLink(shouldCreate = true)
      ndk = AndroidBuilder.new(@arch)
      if @arch == Arch.armv7a
         targetFile = "/usr/bin/armv7-none-linux-androideabi-ld.gold"
         if shouldCreate
            message "Making symbolic link to \"#{targetFile}\"..."
            execute "sudo ln -svf #{ndk.sources}/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/arm-linux-androideabi/bin/ld.gold #{targetFile}"
         else
            message "Removing previously created symlink: \"#{targetFile}\"..."
            execute "sudo rm -fv #{targetFile}"
         end
         execute "ls -al /usr/bin/*ld.gold"
      end
   end

   def addFile(replacementFile, destinationFile, shouldApply = true)
      if shouldApply
         if !File.exist? destinationFile
            puts "Applying fix \"#{@component}\"..."
            execute "cp -vf \"#{replacementFile}\" \"#{destinationFile}\""
         else
            puts "File \"#{destinationFile}\" exists. Seems you already applied fix for \"#{@component}\". Skipping..."
         end
      else
         message "Removing previously applied fix..."
         if File.exist? destinationFile
            execute "rm -fv #{destinationFile}"
         end
      end
   end

   def configurePatch(originalFile, patchFile, shouldApply = true)
      gitRepoRoot = "#{Config.sources}/#{@component}"
      backupFile = "#{originalFile}.orig"
      if shouldApply
         if !File.exist? backupFile
            puts "Patching \"#{@component}\"..."
            execute "patch --backup #{originalFile} #{patchFile}"
         else
            puts "Backup file \"#{backupFile}\" exists. Seems you already patched \"#{@component}\". Skipping..."
         end
      else
         message "Removing previously applied patch..."
         execute "cd \"#{gitRepoRoot}\" && git checkout #{originalFile}"
         if File.exist? backupFile
            execute "rm -fv #{backupFile}"
         end
      end
   end

   def checkoutIfNeeded(localPath, repoURL, revision)
      if File.exist?(localPath)
         message "Repository \"#{repoURL}\" seems already checked out to \"#{localPath}\"."
      else
         execute "mkdir -p \"#{localPath}\""
         # Checking out specific SHA - https://stackoverflow.com/a/43136160/1418981
         execute "cd \"#{localPath}\" && git init && git remote add origin \"#{repoURL}\""
         execute "cd \"#{localPath}\" && git config --local uploadpack.allowReachableSHA1InWant true"
         execute "cd \"#{localPath}\" && git fetch --depth 10 origin #{revision}"
         # Disable warning about detached HEAD - https://stackoverflow.com/a/45652159/1418981
         execute "cd \"#{localPath}\" && git -c advice.detachedHead=false checkout FETCH_HEAD"
         message "#{repoURL} checkout to \"#{localPath}\" is completed."
      end
   end

end