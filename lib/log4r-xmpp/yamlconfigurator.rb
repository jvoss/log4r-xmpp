# Copyright 2011 Jonathan P. Voss
#
# This file is part of Log4r-XMPP
#
# Log4r-XMPP is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option)
# any later version.
#
# Log4r-XMPP is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License
# along with Log4r-XMPP. If not, see <http://www.gnu.org/licenses/>.
#

require 'log4r/yamlconfigurator'

module Log4r

  class YamlConfigurator

    # Monkey patches paramsub to accept arrays as hash values
    #
    def self.paramsub( str)

      return nil if str.nil?

      return nil if str.class != String && str.class != Array

      @@params.each do |param, value|

        [str].flatten.each{ |e| e.sub!('#{' + param + '}', value) }

      end # @@params.each

      str.class == String ? "'" + str + "'" : str.inspect

    end # def self.paramsub

  end # class YamlConfigurator

end # module Log4r
