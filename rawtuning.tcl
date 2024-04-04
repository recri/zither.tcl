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

#
# this isn't really useful as it is, I've been experimenting with different
# organizations and this is just a compendium or things people say
#
# the guitar tunings in particular, most of the tunings should be converted
# to interval + root because they're all the same
#
# various conventions for guitar tunings, upper case for octave 2 notes,
# lower case for octave 3, lower case' for octave 4.  standard EADgbe'

package provide ::rawtuning 1.0

package require ::midi

namespace eval ::rawtuning {
    set flat {♭}
    set sharp {♯}
    set dash {–}
    set tunings [dict create {*}{

	3 {
	    dulcimer {
		traditional-1 {G3 G3 C3}
		traditional-2 {C4 G3 C3}
		traditional-3 {C4 F3 C3}
		modern-1 {A3 A3 D3}
		modern-2 {D4 A3 D3}
		modern-3 {D4 G3 D3}
	    }
	}

	4 {
	    dulcimer {
		traditional-1 {G3 G3 G3 C3}
		traditional-2 {C4 C4 G3 C3}
		traditional-3 {C4 C4 F3 C3}
		modern-1 {A3 A3 A3 D3}
		modern-2 {D4 D4 A3 D3}
		modern-3 {D4 D4 G3 D3}
	    }

	    violin {
		standard {G3 D4 A4 E5}
		cajun    {F3 C4 G4 D5}
		open-G   {G3 D4 G4 B4}
		sawmill  {G3 D4 G4 D5}
		gee-dad  {G3 D4 A4 D5}
		dead-man {D4 D4 A4 D5}
		high-bass {A3 D4 A4 E5}
		cross-tuning {A3 E4 A4 E5}
		calico       {A3 E4 A4 C#5}
		old-sledge   {A3 E4 A4 D5}
		glory-in-the-meeting-House {E3 D4 A4 E5}
		get-up-in-the-cool {E4 E4 A4 E5}
	    }

	    banjo {
		standard {C3 G3 D4 A4}
	    }

	    ukulele {
		pocket {D5 G4 B4 E5}
		pocket-alt {C5 F4 A4 D5}
		soprano {G4 C4 E4 A4}
		soprano-alt-1 {A4 D4 F#4 B4}
		soprano-alt-2 {G3 C4 E4 A4}
		concert {G4 C4 E4 A4}
		concert-alt {G3 C4 E4 A4}
		tenor {G4 C4 E4 A4}
		tenor-alt-1 {D4 G3 B3 E4}
		tenor-alt-2 {A3 D4 F#4 }
		tenor-alt-3 {D3 G3 B3 E4}
		baritone {D3 G3 B3 E4}
		baritone-alt {C3 G3 B3 E4}
		bass {E1 A1 D2 G2}
		bass-alt {D1 A1 D2 G2}
	    }

	    bass-guitar {
		standard {E1 A1 D2 G2}
	    }
	}

	5 {
	    banjo {
		standard {G4 C3 G3 B3 D4}
		open-G {G4 D3 G3 B3 D4}
		open-G-alt {G4 C3 G3 B3 D4}
		double-C {G4 C3 G3 C4 D4}
		sawmill {G4 D3 G3 C4 D4}
		open-D {F#4 D3 F#3 A3 D4} 
		double-D {A4 D3 A3 D4 E4}
		open-A {A4 E3 A3 C#4 E4}
	    }

	    bass-guitar {
		low {B0 E1 A1 D2 G2}
		high {E1 A1 D2 G2 C3}
	    }

	    guitar {
		standard {A2 D3 G3 B3 E4}
	    }
	}

	6 {
	    guitar {
		standard {E2 A2 D3 G3 B3 E4}
		trivial {E2 E2 E3 E3 E4 E4}
		minor-thirds { C2–Eb2–Gb2–A2–C3–Eb3 B2–D3–F3–Ab3–B3–D4 }
		major-thirds {E2 G#2 C3 E3 G#3 C4}
		all-fourths {E2 A2 D3 G3 C4 F4}
		augmented-fourths { C2–F#2–C3–F#3–C4–F#4 B1–F1–B2–F3–B3–F4 }
		all-fifths {C2 G2 D3 A3 E4 B4}
		drop-D {D2 A2 D3 G3 B3 E4}
		double-drop-D {D2 A2 D3 G3 B3 D4}
		lowered-Eb { Eb Ab Db Gb Bb Eb }
		lowered-D { D G C F A D }
		noted {
		    EADGBE {E2 A2 D3 G3 B3 E4}
		    EADGCF {E2 A2 D3 G3 C4 F4}
		    {EG#CEG#C} {E2 G#2 C3 E3 G#3 C4}
		    CGDAEB {C2 G2 D3 A3 E4 B4}
		    {EBEG#BE} {E2 B2 E3 G#3 B3 E4}
		    {DADF#AD} {D2 A2 D3 F#3 A3 D4}
		    DADGAG {D2 A2 D3 G3 A3 G4}
		    DGCGCD {D2 G2 C3 G3 C4 D4}
		    CGDGAD {C2 G2 D3 G3 A4 D4}
		    EEEEBE {E2 E2 E3 E3 B3 E4}
		    EEBBBE {E2 E2 B3 B3 B3 E4}
		    EBDGAD EBDGAD
		    DGDGBD DGDGBD
		    {EBEG#BE} {EBEG#BE}
		    {DADF#AD} {DADF#AD}
		    CGCGCE CGCGCE
		}		
		open-major {
		    A { {A2 C#3 E3 A3 C#4 E4} {A2 A3 E3 A4 C#5 E5} {E2 A2 E3 A3 C#4 E4} }
		    B { {B2 D#3 F#3 B3 D#4 F#4} {B2 B3 F#4 B D# F#} {F#2 B D# F# B F#} }
		    C { { C2 E G C E G } { C2 E G# C E G# } { C2 E Ab C E Ab } { C2 G C G G E }
			{ C2 G C G C E } { C2 C G C E G } { C2 G D A E G } { C2 C G C E C } }
		    D { { D2 F# A D F# A } { D2 D A D F# A } { D2 A2 D3 F#3 A3 D4 } }
		    E { { E2 G#2 B2 E3 G#3 B3 } { E2 E3 B3 E4 G#3 B3 } { E2 B2 E3 G#3 B3 E4 } }
		    F { { F2 A2 C3 F3 A3 C4 } { F2 F2 C3 F3 A3 C4 } { C2 F2 C3 F3 A3 F4 } }
		    G { { G2 B2 D3 G3 B3 D4 } { G2 G2 D3 G3 B3 D4 } { D2 G2 D3 G3 B3 D4 } { D2 G2 D3 G3 B3 E4 } }
		}
		power-chord-fifths {
		    A { E A E A A E }
		    B { F# B F# B B F# }
		    C { C G C G G G }
		    D { D A D A D D }
		    E { E B E E B E }
		    F { F C C C C F }
		    G { D G D G D G }
		}
		open-minor {
		    C { C C G C Eb G }
		    E { E B E G B E }
		}
		open-modal {
		    C { C G D G B D }
		    D { D G D G B E }
		}
		lowered-standard {
		    Eb Eb-Ab-Db-Gb-Bb-Eb
		    D D-G-C-F-A-D
		}
	    }
	}

	7 {
	    string-guitar  {
		standard {D2 G2 B2 D3 G3 B3 D4}
	    }
	    lyre {
		standard {D4 E4 G4 A4 B4 D5 E5}
	    }
	}
	
	8 {
	    mandolin {
		standard {G3 G3 D4 D4 A4 A4 E5 E5}
	    }
	}

	8 {
	    stick {
		1 {B0 E1 A1 D2 G2 C3 F3 Bb3}
		2 {B0 E1 A1 D2 G2 C3 E3 A3}
		3 {B0 E1 A1 D2 G2 B2 E3 A3}
		4 {A2 D2 G1 C1 E2 A2 D3 G3}
		5 {A2 D2 G1 C1 F#2 B2 E3 A3}
	    }
	}
	
	10 {
	    guitar {
		concat {E1 A1 D2 G2 E2 A2 D3 G3 B3 E4}
	    }
	    stick {
		1 {E3 A2 D2 G1 C1 E2 A2 D3 G3 C4}
		2 {E3 A2 D2 G1 C1 F#2 B2 E3 A3 D4}
		3 {E3 A2 D2 G1 C1 C#2 F#2 B2 E3 A3}
		4 {E3 A2 D2 G1 C1 B1 E2 A2 D3 G3}
		5 {D3 G2 C2 F1 Bb0 D2 G2 C3 F3 Bb3}
		6 {F#3 B2 E2 A1 D1 F#2 B2 E3 A3 D4}
		7 {F#3 B2 E2 A1 D1 C#2 F#2 B2 E3 A3}
		8 {D#3 G#2 C#2 F#1 B0 E2 A2 D3 G3 C4}
	    }
	}
	
	12 {
	    guitar {
		standard {E1 E2 A1 A2 D2 D3 G2 G3 B3 B3 E4 E4}
	    }
	    stick {
		1 {B3 E3 A2 D2 G1 C1 B1 E2 A2 D3 G3 C4}
		1 {B3 E3 A2 D2 G1 C1 C#2 F#2 B2 E3 A3 D3}
	    }
	}

	16 {
	    lyre {G3 A3 B3 C4 D4 E4 F4 G4 A4 B4 C5 D5 E5 F5 G5 A5}
	}

	38 {
	    zither {
		viennese {A4 D4 G4 G3 C3 Ab4 Eb4 Bb3 F4 C4 G4 D4 A3 E4 B3 F#4 C#4 G#3 Eb2 Bb2 F2 C3 G2 D2 A2 E2 B2 F#2 C#2 G#2 C2 B1 Bb1 A1 G#1 G1 F#1 F1}
	    }
	}

	42 {
	    zither {
		munich {A4 A4 D4 G3 C3 | Eb4 Bb3 F4 C4 G3 D4 A3 E4 B3 F#3 C#4 G#3 | Eb3 Bb2 F3 C3 G2 D3 A2 E3 B2 F#2 C#3 G#2 | F2 E2 Eb2 D2 C#2 C2 | B1 Bb1 A1 G#1 G1 F#1 F1}
	    }
	}

	45 {
	    15/14-hammered-dulcimer {
		standard {0 2 4 5 7 9 10 12 14 15 17 19 20 22 | 6 7 9 11 12 14 16 17 19 21 22 24 26 27 29 | 13 14 16 18 19 21 23 24 26 28 29 31 33 34 36 38}
	    }
	}
	    
    }]
}

proc ::rawtuning::keys-dict {} {dict keys $::rawtuning::tunings}
proc ::rawtuning::get-dict {args} {dict get $::rawtuning::tunings {*}$args}

# munich zither fretted a a d g c (a == 440)
# accompaniment eb bb f c g d a e b f# c# g#
# bass Eb Bb F C G D A E B F# C# G#
# contrabass F E Eb D C# C B Bb A G# G F# FF		 

    #
# take tunings as lists of notename octaves
# and other formats to be determined, and 
# translate to preset format:
# tuning - the set of intervals between strings
# root - the open note of the string closest to the player
# strings - the number of strings
#
proc ::rawtuning::to-preset {key value} {
    # puts "$key $value" 
    set strings [llength $value]
    set root [lindex $value 0]
    set tuning {}
    set notes [lmap note $value {::midi::name-octave-to-note $note}]
    for {set i 0} {$i < $strings} {incr i} {
	if {$i == 0} { 
	    set interval 0
	} else {
	    set interval [expr {[lindex $notes $i]-[lindex $notes $i-1]}]
	}
	lappend tuning $interval
    }
    if {0} {
	switch -regexp $tuning {
	    {^0( +4)+$} { set tuning thirds }
	    {^0( +5)+$} { set tuning fourths }
	    {^0( +7)+$} { set tuning fifths }
	    {^0 +0( +7 +0)+$} { set tuning doubled-fifths }
	}
    }
    set notes2 {}
    foreach interval $tuning {
	if {$notes2 eq {}} {
	    set note2 $root
	} else {
	    set note2 [::midi::note-to-name-octave [expr {$interval+[::midi::name-octave-to-note [lindex $notes2 end]]}]]
	}
	lappend notes2 $note2
    }
    # foreach n1 $value n2 $notes2 { if {$n1 ne $n2} { error "mismatch between $value and $notes2" } }
    return "$key { strings $strings root $root tuning {$tuning}}"
}

