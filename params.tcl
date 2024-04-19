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
	dev /dev/input/event10
	fullscreen 1
	height 800
	width 480
    }
    # params of muscial interest
    # 	preset bass-guitar-4  strings 4 root E1 tuning {0  5 5 5}

    array set ::params::defaults {
	instrument {bass-guitar 4}
	strings single
	tuning standard
	tonic C
	mode Ionian
	nut 0
	frets 24
	sound bass
	color-scales 0
	hide-offscales 0
	label-notes 1
	more-scale-colors {
	    bamO {
		#4f382fb44383 #79013fa66be5 #a0dc5eb09121 #c29a8584b280 #d835b0dcca1a #d945c8c8ca61 #cf21cdd8bbe1 #abbeb8fd8f75 #83c0916e6540 #67ca6e3e4d7c #53d350723faa #49df3ca63a70
	    }

	    brocO {
		#36db2f4637dc #369e393b5715 #415457b280ce #611b7f4aa52c #8adca401bf7c #b585c494d012 #cfbfd446c560 #c2ffc3169bb4 #9f0f9e936c66 #758c74ac450c #53f551262df9 #3f0f38a82985
	    }
	    corkO {
		#3f1b3e563aac #3dc83f3f51ed #447555117865 #5f0b7aae9fd9 #844b9e81ba9b #a68fbd60c8b5 #af51cb4fbca1 #96cabee799c6 #7356a3346ef6 #547a7d5b43ec #465d5d622e3d #41c749772e62
	    }
	    romaO {
		#738c39345784 #828c3bde3d3d #941e4fd62dd1 #aaf475552f24 #c3bba3ca4bc7 #d5afcf268107 #cbc2e219b382 #a4fbd8f3cc0b #7494bbd3ce31 #535993a2bff6 #515a6b95a512 #622349a97dad
	    }
	    vikO {
		#4f4e19d43d09 #3fbd2bcf5b37 #33874b767f2f #455c756fa16f #75939ec0bc86 #ae95bdd1c8e8 #d577bf0ab3a9 #d7eea386871e #c5b27bfe5669 #a1834b7c2bdf #7ab7256b1e52 #610315fe2797
	    }
	}
	scale-colors {
	    #4f4e19d43d09 #3fbd2bcf5b37 #33874b767f2f #455c756fa16f #75939ec0bc86 #ae95bdd1c8e8 #d577bf0ab3a9 #d7eea386871e #c5b27bfe5669 #a1834b7c2bdf #7ab7256b1e52 #610315fe2797
	}
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
