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

package provide ::window 1.0

package require ::params
package require ::midi
package require ::presets
package require ::evdev

# data in the menu

namespace eval ::window {

    proc adjust {w which {redraw 1}} {

	# the fretboard is a rectangle of "buttons" frets wide and strings high
	# which has a tuning specified by the root note in the lower left corner
	switch $which {
	    orientation {	# fretboard layout on screen
	    }
	    frets {	# the number of frets on the fretboard
	    }
	    strings {	# the number of strings on the fretboard
	    }
	    root {	# the note of the open string at bottom/closest to player
	    }
	    tuning {	# the intervals between strings starting from the root
	    }
	    tonic {	# the tonic is the note which is the root of the scale
	    }
	    mode {	# the mode determines which scale is labelled from the root
	    }
	    nut {	# nut shifts the whole fretboard by semitones
	    }
	    preset {	# presets define frets, strings, root, and tuning
		# puts "preset $::window::data(preset) -> [::presets::value $::window::data(preset)]"
		foreach {key val} [::presets::value $::window::data(preset)] {
		    set ::window::data($key) $val
		}
		adjust $w $key 0
	    }
	    sound {
		::sound::select $::window::data(sound)
	    }
	    default {
		error "no case for $which in adjust"
	    }
	}
	redraw $w
    }

    proc redraw {w} {
	$w.c delete all
	set cwid [winfo width $w.c]
	set chgt [winfo height $w.c]
	set fwid [expr {$cwid/double($::window::data(frets))}]
	set shgt [expr {$chgt/double($::window::data(strings))}]
	set keynote [::midi::name-to-note $::window::data(tonic)]
	set scalenotes [lmap n [::midi::get-mode $::window::data(mode)] {expr {($keynote+$n)%12}}]

	
	set ::window::data(cwid) $cwid
	set ::window::data(chgt) $chgt
	set ::window::data(fwid) $fwid
	set ::window::data(shgt) $shgt
	
	set in 4
	set x0 $in
	set y0 $in
	set xm [expr {$fwid/2.0}]
	set ym [expr {$shgt/2.0}]
	set xc [expr {$fwid-$in}]
	set yc [expr {$shgt-$in}]
		
	set button [list $x0 $y0 $x0 $ym $x0 $yc $xm $yc $xc $yc $xc $ym $xc $y0 $xm $y0]

	if {{MyButtonFont} ni [font names]} {
	    font create MyButtonFont {*}[font configure TkHeadingFont] -size 16
	}

	array unset ::window::stringnote

	for {set string 0} {$string < $::window::data(strings)} {incr string} {
	    if {$string == 0} {
		set ::window::stringnote($string) [expr {[::midi::name-octave-to-note $::window::data(root)]+$::window::data(nut)}]
	    } else {
		set previous [expr {$string-1}]
		set ::window::stringnote($string) [expr {$::window::stringnote($previous)+[lindex $::window::data(tuning) $string]}]
	    }
	    for {set fret 0} {$fret < $::window::data(frets)} {incr fret} {
		foreach {x y} [fret-to-window $string $fret] break;
		set xc [expr {$x+$fwid}]
		set yc [expr {$y+$shgt}]
		set p [$w.c create polygon $button -outline white -fill {} -smooth true]
		$w.c move $p $x $y
		# label button
		set l [$w.c create text [expr {$x+0.5*$fwid}] [expr {$y+0.5*$shgt}] -text "$string.$fret" -anchor c -fill white -font MyButtonFont]
		# label with notes
		set note [expr {$::window::stringnote($string)+$fret}]
		$w.c itemconfigure $l -text [::midi::note-to-name $note] -angle [expr {90+$::window::data(orientation)}]
		if {[lsearch -exact -integer $scalenotes [expr {$note % 12}]] >= 0} {
		    $w.c itemconfigure $l -text [::midi::note-to-name $note]
		    if {$keynote == ($note % 12)} {
			# highlight the tonic
			$w.c itemconfigure $p -width 5 -outline white
		    } else {
			# emphasize the scale
			$w.c itemconfigure $p -width 2 -outline white
		    }
		} else {
		    # deemphasize the accidentals
		    $w.c itemconfigure $l -fill darkgrey
		    $w.c itemconfigure $p -width 1 -outline grey20
		}
	    }
	}
    }
    
    # translate window coordinates, x and y increasing from upper right corner
    # into string and fret
    proc window-to-fret {x y} {
	switch $::window::data(orientation) {
	    0 {
		set s [expr {int(($::window::data(chgt)-$y)/$::window::data(shgt))}]
		set f [expr {int($x/$::window::data(fwid))}]
	    }
	    180 {
		set s [expr {int($y/$::window::data(shgt))}]
		set f [expr {$::window::data(frets)-int($x/$::window::data(fwid))-1}]
	    }
	}
	list $s $f
    }

    # translate string and fret coordinates into window coordinates
    proc fret-to-window {string fret} {
	switch $::window::data(orientation) {
	    0 {
		set x [expr {$fret*$::window::data(fwid)}]
		set y [expr {($::window::data(strings)-($string+1.0))*$::window::data(shgt)}];
	    }
	    180 {
		set x [expr {($::window::data(frets)-$fret-1)*$::window::data(fwid)}]
		set y [expr {$string*$::window::data(shgt)}]
	    }
	}
	list $x $y
    }
    
    proc note {action id x y} {
	foreach {string fret} [window-to-fret $x $y] break
	sound::note $action $id [midi::mtof [expr {$::window::stringnote($string)+$fret}]]
    }

    proc max-width {list} {
	tcl::mathfunc::max {*}[lmap i $list {string length $i}]
    }

    proc control {w} {
	if {[winfo exists $w.controls]} { destroy $w.controls }

	# controls
	toplevel $w.controls
	
	# spinbox of keys
	set keys [::midi::get-keys]
	set width [max-width $keys]
	pack [labelframe $w.controls.key -text {Tonic}] -side top -fill x -expand true
	pack [spinbox $w.controls.key.spin -textvariable ::window::data(tonic) -width $width -values $keys -command [list ::window::adjust $w tonic]]
	
	# spinbox of modes
	set modes [::midi::get-modes]
	set width [max-width $modes]
	pack [labelframe $w.controls.mode -text {Mode}] -side top -fill x -expand true
	pack [spinbox $w.controls.mode.spin -textvar ::window::data(mode) -width $width -values $modes -command [list ::window::adjust $w mode]]
	
	# spinbox of nut semitone offsets from specified preset
	set width 3
	pack [labelframe $w.controls.nut -text {Nut}] -side top -fill x -expand true
	pack [spinbox $w.controls.nut.spin -textvar ::window::data(nut) -width $width -from -24 -to 24 -increment 1 -command [list ::window::adjust $w nut]]
	
	# spinbox of frets
	pack [labelframe $w.controls.frets -text {Frets}] -side top -fill x -expand true
	pack [spinbox $w.controls.frets.spin -textvar ::window::data(frets) -width 2 -from 1 -to 36 -increment 1  -command [list ::window::adjust $w frets]]
	
	# menu of presets
	# FIX.ME - go to multi level menu
	set presets [::presets::keys]
	set width [max-width $presets]
	pack [labelframe $w.controls.preset -text {Preset}] -side top -fill x -expand true
	pack [spinbox $w.controls.preset.spin -textvar ::window::data(preset) -width $width -values $presets -command [list ::window::adjust $w preset]]

	# menu of sounds
	set sounds [::sound::list-sounds]
	set width [max-width $sounds]
	pack [labelframe $w.controls.sound -text {Sound}] -side top -fill x -expand true
	pack [spinbox $w.controls.sound.spin -textvar ::window::data(sound) -width $width -values $sounds -command [list ::window::adjust $w sound]]

	# set default values
	array set ::window::data [array get params::defaults]
	
	# control buttons
	pack [button $w.controls.done -text Dismiss -command [list destroy $w.controls]] -side top -fill x -expand true
	pack [button $w.controls.quit -text Quit -command {destroy .}] -side top -fill x -expand true
	pack [button $w.controls.panic -text Panic -foreground red -command {sound::stop}] -side top -fill x -expand true
    }

    proc main {w} {
	# canvas fretboard
	pack [canvas $w.c] -side top -fill both -expand true

	# set default values, first time
	array set ::window::data [array get ::params::defaults]
	
	# set default values, second time
	foreach {key value} [array get ::window::data] { ::window::adjust $w $key }

	bind $w.c <Configure> [list ::window::redraw  $w]
	bind $w.c <Button-3> [list ::window::control $w]

	if {$::params::touch} {
	    bind $w.c <<TouchBegin>> {::window::note + %d %x %y}
	    bind $w.c <<TouchUpdate>> {::window::note . %d %x %y}
	    bind $w.c <<TouchEnd>> {::window::note - %d %x %y}
	}
	if {$::params::mouse} {
	    bind $w.c <ButtonPress-1> {::window::note + f %x %y}
	    bind $w.c <B1-Motion> {::window::note . f %x %y}
	    bind $w.c <ButtonRelease-1> {::window::note - f %x %y}
	}
    }
}
