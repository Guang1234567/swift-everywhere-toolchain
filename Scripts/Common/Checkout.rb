#
# The MIT License
#
# Copyright (c) 2019 Volodymyr Gorlov (https://github.com/vgorloff)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

require_relative "Tool.rb"

class Checkout < Tool

   def checkout()
      checkoutIfNeeded("#{Config.sources}/#{Lib.llvm}", "https://hub.fastgit.org/apple/llvm-project.git", Revision.llvm)
      checkoutIfNeeded("#{Config.sources}/#{Lib.swift}", "https://hub.fastgit.org/apple/swift.git", Revision.swift)
      checkoutIfNeeded("#{Config.sources}/#{Lib.foundation}", "https://hub.fastgit.org/apple/swift-corelibs-foundation", Revision.foundation)
      checkoutIfNeeded("#{Config.sources}/#{Lib.dispatch}", "https://hub.fastgit.org/apple/swift-corelibs-libdispatch.git", Revision.dispatch)
      checkoutIfNeeded("#{Config.sources}/#{Lib.cmark}", "https://hub.fastgit.org/apple/swift-cmark.git", Revision.cmark)
      checkoutIfNeeded("#{Config.sources}/#{Lib.icu}", "https://hub.fastgit.org/unicode-org/icu.git", Revision.icu)
      checkoutIfNeeded("#{Config.sources}/#{Lib.ssl}", "https://hub.fastgit.org/openssl/openssl.git", Revision.ssl)
      checkoutIfNeeded("#{Config.sources}/#{Lib.curl}", "https://hub.fastgit.org/curl/curl.git", Revision.curl)
      checkoutIfNeeded("#{Config.sources}/#{Lib.xml}", "https://hub.fastgit.org/GNOME/libxml2.git", Revision.xml)
      checkoutIfNeeded("#{Config.sources}/#{Lib.spm}", "https://hub.fastgit.org/apple/swift-package-manager.git", Revision.spm)
      checkoutIfNeeded("#{Config.sources}/#{Lib.llb}", "https://hub.fastgit.org/apple/swift-llbuild.git", Revision.llb)
   end

   def fetch()
      fetchIfNeeded("#{Config.sources}/#{Lib.llvm}", "https://hub.fastgit.org/apple/llvm-project.git", Revision.llvm)
      fetchIfNeeded("#{Config.sources}/#{Lib.swift}", "https://hub.fastgit.org/apple/swift.git", Revision.swift)
      fetchIfNeeded("#{Config.sources}/#{Lib.foundation}", "https://hub.fastgit.org/apple/swift-corelibs-foundation", Revision.foundation)
      fetchIfNeeded("#{Config.sources}/#{Lib.dispatch}", "https://hub.fastgit.org/apple/swift-corelibs-libdispatch.git", Revision.dispatch)
      fetchIfNeeded("#{Config.sources}/#{Lib.cmark}", "https://hub.fastgit.org/apple/swift-cmark.git", Revision.cmark)
      fetchIfNeeded("#{Config.sources}/#{Lib.icu}", "https://hub.fastgit.org/unicode-org/icu.git", Revision.icu)
      fetchIfNeeded("#{Config.sources}/#{Lib.ssl}", "https://hub.fastgit.org/openssl/openssl.git", Revision.ssl)
      fetchIfNeeded("#{Config.sources}/#{Lib.curl}", "https://hub.fastgit.org/curl/curl.git", Revision.curl)
      fetchIfNeeded("#{Config.sources}/#{Lib.xml}", "https://hub.fastgit.org/GNOME/libxml2.git", Revision.xml)
   end

   # Private

   def fetchIfNeeded(localPath, repoURL, revision)
      if File.exist?(localPath)
         execute "cd \"#{localPath}\" && git fetch --prune origin && git fetch --all --tags --progress"
      else
         checkoutIfNeeded(localPath, repoURL, revision)
      end
   end

   def checkoutIfNeeded(localPath, repoURL, revision)
      if File.exist?(localPath)
         cmd = "cd \"#{localPath}\" && git rev-parse --verify HEAD"
         sha = `#{cmd}`.strip()
         cmd = "cd \"#{localPath}\" && git branch | grep \\* | cut -d ' ' -f2"
         branch = `#{cmd}`.strip()
         expectedBranchName = branchName(revision)
         if revision == sha && expectedBranchName == branch
            message "Repository \"#{repoURL}\" already checked out to \"#{localPath}\"."
         else
            checkoutRevision(localPath, revision)
            message "#{localPath} updated to revision #{revision}."
         end
      else
         execute "mkdir -p \"#{localPath}\""
         # Checking out specific SHA - https://stackoverflow.com/a/43136160/1418981
         execute "cd \"#{localPath}\" && git init && git remote add origin \"#{repoURL}\""
         checkoutRevision(localPath, revision)
         message "#{repoURL} checkout to \"#{localPath}\" is completed."
      end
   end

   def checkoutRevision(localPath, revision)
      branch = branchName(revision)
      message "Checking out revision #{revision}"
      execute "cd \"#{localPath}\" && git fetch --prune origin && git fetch --all --tags --progress"
      # Disable warning about detached HEAD - https://stackoverflow.com/a/45652159/1418981
      execute "cd \"#{localPath}\" && git -c advice.detachedHead=false checkout #{revision}"
      execute "cd \"#{localPath}\" && git branch -f #{branch}"
      execute "cd \"#{localPath}\" && git checkout #{branch}"
   end

   def branchName(revision)
      return "swift-toolchain-v#{@version}@sha-" + revision[0..16]
   end

end
