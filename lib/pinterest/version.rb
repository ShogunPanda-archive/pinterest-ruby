#
# This file is part of the pinterest-ruby gem. Copyright (C) 2017 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

module Pinterest
  # The current version of pinterest-ruby, according to semantic versioning.
  #
  # @see http://semver.org
  module Version
    # The major version.
    MAJOR = 1

    # The minor version.
    MINOR = 0

    # The patch version.
    PATCH = 1

    # The current version of pinterest-ruby.
    STRING = [MAJOR, MINOR, PATCH].compact.join(".")
  end
end
