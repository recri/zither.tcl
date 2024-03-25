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

package provide ::tuning 1.0

namespace eval ::tuning {
    set tunings [dict create {*}{
	3-string-dulcimer {
	    trad-1 {G3 G3 C3}
	    trad-2 {C4 G3 C3}
	    trad-3 {C4 F3 C3}
	    mod-1 {A3 A3 D3}
	    mod-2 {D4 A3 D3}
	    mod-3 {D4 G3 D3}
	}
	4-string-banjo {
	    std {C3 G3 D4 A4}
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
	    tenor-alt-2 {A3 D4 F#4}
	    tenor-alt-3 {D3 G3 B3 E4}
	    baritone {D3 G3 B3 E4}
	    baritone-alt {C3 G3 B3 E4}
	    bass {E1 A1 D2 G2}
	    bass-alt {D1 A1 D2 G2}
	}
	5-string-banjo {
	    std {G4 C3 G3 B3 D4}
	    open-G {G4 D3 G3 B3 D4}
	    open-G-alt {G4 C3 G3 B3 D4}
	    double-C {G4 C3 G3 C4 D4}
	    sawmill {G4 D3 G3 C4 D4}
	    open-D {F#4 D3 F#3 A3 D4} 
	    double-D {A4 D3 A3 D4 E4}
	    open-A {A4 E3 A3 C#4 E4}
	}
	5-bass-guitar {
	    low {B0 E1 A1 D2 G2}
	    high {E1 A1 D2 G2 C3}
	}
	5-string-guitar {
	    standard {A2 D3 G3 B3 E4}
	}
	6-string-guitar {
	    standard {E2 A2 D3 G3 B3 E4}
	    all-fourths {E2 A2 D3 G3 C4 F4}
	    major-thirds {E2 G#2 C3 E3 G#3 C4}
	    all-fifths {C2 G2 D3 A3 E4 B4}
	    drop-D {D2 A2 D3 G3 B3 E4}
	    double-drop-D {D2 A2 D3 G3 B3 D4}
	}
	7-string-guitar  {
	    standard {D2 G2 B2 D3 G3 B3 D4}
	}
	12-string-guitar {
	    standard {{E1 E2} {A1 A2} {D2 D3} {G2 G3} {B3 B3} {E4 E4}}
	}
	4-string-bass-guitar {
	    standard {E1 A1 D2 G2}
	}
	zither {
	    munich {A4 A4 D4 G3 C3 | Eb4 Bb3 F4 C4 G3 D4 A3 E4 B3 F#3 C#4 G#3 | Eb3 Bb2 F3 C3 G2 D3 A2 E3 B2 F#2 C#3 G#2 | F2 E2 Eb2 D2 C#2 C2 | B1 Bb1 A1 G#1 G1 F#1 F1}
	    viennese {A4 D4 G4 G3 C3 | Ab4 Eb4 Bb3 F4 C4 G4 D4 A3 E4 B3 F#4 C#4 | G#3 Eb2 Bb2 F2 C3 G2 D2 A2 E2 B2 F#2 C#2 | G#2 C2 B1 Bb1 A1 G#1 | G1 F#1 F1}
	}
	15/14-hammered-dulcimer {
	    standard {0 2 4 5 7 9 10 12 14 15 17 19 20 22 | 6 7 9 11 12 14 16 17 19 21 22 24 26 27 29 | 13 14 16 18 19 21 23 24 26 28 29 31 33 34 36 38}
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
	    get-up-in-the-cool {E E A E}
	}
	mandolin {
	    standard {{G3 G3} {D4 D4} {A4 A4} {E5 E5}}
	}
	7-string-lyre {
	    std {D4 E4 G4 A4 B4 D5 E5}
	}
	16-string-lyre {
	    std {G3 A3 B3 C4 D4 E4 F4 G4 A4 B4 C5 D5 E5 F5 G5 A5}
	}
    }]
    set tunings [dict create {*}{
	dulcimer-3 {D4 A3 D3}
	dulcimer-4 {D4 D4 A3 D3}
	bass-guitar-4 {E1 A1 D2 G2}
	banjo-4 {C3 G3 D4 A4}
	bass-guitar-low-5 {B0 E1 A1 D2 G2}
	bass-guitar-high-5 {E1 A1 D2 G2 C3}
	banjo-5 {G4 C3 G3 B3 D4}
	sawmill-5 {G4 D3 G3 C4 D4}
	guitar-6 {E2 A2 D3 G3 B3 E4}
	fourths-6 {E2 A2 D3 G3 C4 F4}
	major-thirds-6 {E2 G#2 C3 E3 G#3 C4}
	fifths-6 {C2 G2 D3 A3 E4 B4}
	guitar-7 {D2 G2 B2 D3 G3 B3 D4}
	guitar-12 {E1 E2 A1 A2 D2 D3 G2 G3 B3 B3 E4 E4}
	violin {G3 D4 A4 E5}
	mandolin {G3 G3 D4 D4 A4 A4 E5 E5}
	lyre-7 {D4 E4 G4 A4 B4 D5 E5}
	lyre-16 {G3 A3 B3 C4 D4 E4 F4 G4 A4 B4 C5 D5 E5 F5 G5 A5}
    }]
}    
