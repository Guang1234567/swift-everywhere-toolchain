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

require_relative "ICUBaseBuilder.rb"

class ICUSwiftHostBuilder < ICUBaseBuilder

   def initialize()
      super(Lib.icuSwift, Arch.host)
   end

   def executeConfigure
      # See: ./Sources/swift/utils/build-script-impl
      hostSystem = isMacOS? ? "MacOSX" : "Linux"
      cmd = ["cd #{@builds} &&"]
      cmd << "CFLAGS='-Os'"
      cmd << "CXXFLAGS='--std=c++11 -fPIC'"
      cmd << "#{@sources}/source/runConfigureICU #{hostSystem} --prefix=#{@installs}"

      # Below option should not be set. Otherwize you will have ICU without embed data.
      # See:
      # - ICU Data - ICU User Guide: http://userguide.icu-project.org/icudata#TOC-Building-and-Linking-against-ICU-data
      # - https://forums.swift.org/t/partial-nightlies-for-android-sdk/25909/43?u=v.gorlov
      # cmd << --enable-tools=no"

      cmd << "--enable-renaming --with-library-suffix=swift" # These options can cause a trouble. If not working look how other ICU builders are configured.
      cmd << "--enable-shared --enable-strict --disable-icuio --disable-plugins --disable-dyload"
      cmd << "--disable-extras --disable-samples --enable-tests=no --disable-layoutex --with-data-packaging=library"
      execute cmd.join(" ")
   end

   def executeBuild
      execute "cd #{@builds} && make"
   end

   def executeInstall
      execute "cd #{@builds} && make install"
      applyRenamingFix()
   end

end
