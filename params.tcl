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
# 

package provide params 1.0

# /dev/input/mouse0 - synaptics touchpad as mouse
# /dev/input/mouse1 - track point as mouse
# /dev/input/event4 - synaptics touchpad as event
# /dev/input/event5 - track point as event
# /dev/input/event8 - touch screen on rpi41 with no usb keyboard
# /dev/input/event10 - touch screen on rpi41 with usb keyboard plugged in

# preset stick-10-1 strings 10 root E3 tuning {0 -7 -7 -7 -7 16 5 5 5 5}
# preset bass-guitar-6-high strings 6 root E1 tuning {0 5 5 5 5 5}

namespace eval ::params {
    # params of program interest
    array set ::params::params {
	mouse 0
	touch 1
	dev /dev/input/event11
	fullscreen 1
	height 800
	width 480
	orientation 270
    }
    # params of muscial interest
    # 	preset bass-guitar-4  strings 4 root E1 tuning {0  5 5 5}

    array set ::params::defaults {
	instrument {bass-guitar 4}
	tuning standard
	tonic C
	mode Ionian
	nut 0
	frets 24
	sound bass
    }
    switch $::tcl_platform(machine) {
	x86_64 { 
	    # /dev/input/event4 
	    array set ::params::params {
		mouse 1
		touch 0
		dev {}
		fullscreen 0
	    }
	}
	aarch64 { 
	}
	default { error "unknown machine $::tcl_platform(machine) in params.tcl }
    }
}
