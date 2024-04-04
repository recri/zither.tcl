#!/usr/bin/tclsh

# -*- mode: Tcl; tab-width: 8; -*-
#
# Copyright (C) 2024 by Roger E Critchlow Jr, Las Cruces, NM, USA
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA

# t490
# /dev/input/mouse0 - synaptics touchpad as mouse
# /dev/input/mouse1 - track point as mouse
# /dev/input/event0 - ?
# /dev/input/event1 - ?
# /dev/input/event2 - ?
# /dev/input/event3 - keyboard as event
# /dev/input/event4 - synaptics touchpad as event
# /dev/input/event5 - track point as event
#
# rpi41
# /dev/input/event8 - touch screen on rpi41

lappend auto_path .

package require ::params
package require ::evdev

if {$argv ne {}} {
    set input [lindex $argv 0]
} else {
    set input $::params::dev
}

evdev::input $input

vwait done
