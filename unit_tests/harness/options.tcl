#!/usr/bin/tclsh
#
# Copyright (C) 2014 Fredrik Lindberg <fli@shapeshifter.se>
#
# This file is part of 9pm.
#
# 9pm is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# 9pm is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

package require 9pm
namespace path ::9pm

output::plan 3

output::debug "$argv"

if {[llength $argv] == 2} {
    output::ok "correct number of arguments"
} else {
    output::fail "unexpected number of arguments"
}

if {[lindex $argv 0] == "suite-supplied"} {
    output::ok "argument from suite"
} else {
    output::fail "no argument from suite"
}

if {[lindex $argv 1] == "cmdl-supplied"} {
    output::ok "argument from command line"
} else {
    output::fail "no argument from command line"
}
