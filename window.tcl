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

package provide window 1.0

package require params
package require touch
package require midi
package require rawtuning
package require presets
package require evdev
package require sound

namespace eval ::window {

    variable data
    array set data [array get ::params::defaults]

    variable geom
    array set geom {chgt 0 cwid 0 shgt 0 fwid 0}
    
    variable stringnote 
    array set stringnote {}
    
    proc adjust {w which value {redraw 1}} {
	variable data

	# puts "adjust $w $which $value $redraw -> $data($which)"

	set data($which) $value
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
		foreach {key val} [::presets::value $data(preset)] {
		    adjust $w $key $val 0
		}
	    }
	    sound {
		::sound::select $data(sound)
	    }
	    default {
		error "no case for $which in adjust"
	    }
	}
	if {$redraw} { redraw $w }
    }

    proc redraw {w} {
	variable data
	variable geom
	variable stringnote

	$w.c delete all
	set cwid [winfo width $w.c]
	set chgt [winfo height $w.c]
	set fwid [expr {$cwid/double($data(frets))}]
	set shgt [expr {$chgt/double($data(strings))}]
	set keynote [::midi::name-to-note $data(tonic)]
	set scalenotes [lmap n [::midi::get-mode $data(mode)] {expr {($keynote+$n)%12}}]
	
	set geom(cwid) $cwid
	set geom(chgt) $chgt
	set geom(fwid) $fwid
	set geom(shgt) $shgt
	
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

	foreach name [array names stringnote] { unset stringnote($name) }
	## array unset stringnote

	for {set string 0} {$string < $data(strings)} {incr string} {
	    if {$string == 0} {
		set stringnote($string) [expr {[::midi::name-octave-to-note $data(root)]+$data(nut)}]
	    } else {
		set previous [expr {$string-1}]
		set stringnote($string) [expr {$stringnote($previous)+[lindex $data(tuning) $string]}]
	    }
	    for {set fret 0} {$fret < $data(frets)} {incr fret} {
		foreach {x y} [fret-to-window $string $fret] break;
		set xc [expr {$x+$fwid}]
		set yc [expr {$y+$shgt}]
		set p [$w.c create polygon $button -outline white -fill {} -smooth true]
		$w.c move $p $x $y
		# label button
		set l [$w.c create text [expr {$x+0.5*$fwid}] [expr {$y+0.5*$shgt}] -text "$string.$fret" -anchor c -fill white -font MyButtonFont]
		# label with notes
		set note [expr {$stringnote($string)+$fret}]
		$w.c itemconfigure $l -text [::midi::note-to-name $note $data(tonic)] -angle [expr {90+$::params::params(orientation)}]
		if {[lsearch -exact -integer $scalenotes [expr {$note % 12}]] >= 0} {
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
	switch $::params::params(orientation) {
	    0 {
		set s [expr {int(($::window::geom(chgt)-$y)/$::window::data(shgt))}]
		set f [expr {int($x/$::window::geom(fwid))}]
	    }
	    180 {
		set s [expr {int($y/$::window::geom(shgt))}]
		set f [expr {$::window::data(frets)-int($x/$::window::geom(fwid))-1}]
	    }
	}
	list $s $f
    }

    # translate string and fret coordinates into window coordinates
    proc fret-to-window {string fret} {
	switch $::params::params(orientation) {
	    0 {
		set x [expr {$fret*$::window::geom(fwid)}]
		set y [expr {($::window::data(strings)-($string+1.0))*$::window::geom(shgt)}];
	    }
	    180 {
		set x [expr {($::window::data(frets)-$fret-1)*$::window::geom(fwid)}]
		set y [expr {$string*$::window::geom(shgt)}]
	    }
	}
	list $x $y
    }
    
    proc note {action id x y} {
	variable stringnote
	foreach {string fret} [window-to-fret $x $y] break
	# puts "note $action $id $x $y $string $fret"
	sound::note $action $id [midi::mtof [expr {$stringnote($string)+$fret}]]
    }

    proc max-width {list} {
	tcl::mathfunc::max {*}[lmap i $list {string length $i}]
    }

    proc myoptionmenu {w name text values} {
	variable data
	labelframe $w.controls.$name
	set m [tk_optionMenu $w.controls.$name.options data($name) {*}$values]
	foreach v $values {
	    $m entryconfigure $v -command [list ::window::adjust $w $name $v]
	}
	pack $w.controls.$name.options
	return $w.controls.$name
    }
    
    proc myspinupdate {w name} { ::window::adjust $w $name [$w.controls.$name.spin get] }
    
    proc myspinbox {w name text values} {
	variable data
	labelframe $w.controls.$name -text $text
	pack [spinbox $w.controls.$name.spin -width [max-width $values] -values $values \
		  -command [list ::window::myspinupdate $w $name]]
	$w.controls.$name.spin set $data($name)
	return $w.controls.$name
    }

    proc range {from to increment} {
	set range {}
	for {set i $from} {$i <= $to} {incr i $increment} {
	    lappend range $i
	}
	return $range
    }
    
    proc controls {w} {
	# puts "::window::data [array get ::window::data]"
	if {[winfo exists $w.controls]} { destroy $w.controls }

	# controls
	toplevel $w.controls
	
	# choices
	pack [myoptionmenu $w instrument [::rawtuning::get-instruments]] -side top -fill x -expand true
	pack [myspinbox $w {tonic} {Key} [::midi::get-keys]] -side top -fill x -expand true
	pack [myspinbox $w {mode} {Mode} [::midi::get-modes]] -side top -fill x -expand true
	pack [myspinbox $w {nut} {Nut} [range -24 24 1]] -side top -fill x -expand true
	pack [myspinbox $w {frets} {Frets} [range 1 36 1]] -side top -fill x -expand true
	pack [myspinbox $w {preset} {Preset} [::presets::keys]] -side top -fill x -expand true
	pack [myspinbox $w {sound} {Sound} [::sound::list-sounds]] -side top -fill x -expand true

	# control buttons
	pack [button $w.controls.done -text Dismiss -command [list destroy $w.controls]] -side top -fill x -expand true
	pack [button $w.controls.quit -text Quit -command {destroy .}] -side top -fill x -expand true
	pack [button $w.controls.panic -text Panic -foreground red -command {sound::stop}] -side top -fill x -expand true
    }

    proc main {w args} {
	variable data
	#
	touch::init .c

	# canvas fretboard
	pack [canvas $w.c] -side top -fill both -expand true
	.c configure -width $::params::params(width) -height $::params::params(height) -bg black -bd 0 -highlightthickness 0 -insertborderwidth 0 -selectborderwidth 0

	# set default values, first time
	array set ::window::data [array get ::params::defaults]
	
	# set default values, second time
	foreach {key value} [array get data] { ::window::adjust $w $key $value 0 }
	::window::adjust $w $key $value
	
	bind $w.c <Configure> [list ::window::redraw $w]
	bind $w.c <Button-3> [list ::window::controls $w]

	if {$::params::params(touch)} {
	    bind $w.c <<TouchBegin>> {::window::note + %d %x %y}
	    bind $w.c <<TouchUpdate>> {::window::note . %d %x %y}
	    bind $w.c <<TouchEnd>> {::window::note - %d %x %y}
	}
	if {$::params::params(mouse)} {
	    bind $w.c <ButtonPress-1> {::window::note + f %x %y}
	    bind $w.c <B1-Motion> {::window::note . f %x %y}
	    bind $w.c <ButtonRelease-1> {::window::note - f %x %y}
	}

	foreach {key value} $args {
	    window::adjust $w $key $value
	}

	if {$::params::params(fullscreen)} {
	    after 1 {
		wm attributes . -fullscreen $::params::params(fullscreen)
		# puts [winfo geometry .]
	    }
	}
    }
}
