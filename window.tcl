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
package require instrument
# package require presets
package require evdev
package require sound

namespace eval ::window {
    variable data
    variable geom
    
    proc get-instrument {} { ::instrument::get-instrument $::window::data(instrument) }

    proc get-tunings {} { ::instrument::get-tunings $::window::data(instrument) }
    
    proc get-tuning {} { ::instrument::get-tuning $::window::data(instrument) $::window::data(tuning) }

    proc get-expanded-tuning {} { ::instrument::expand-tuning [get-tuning] }

    proc expand-tuning {} {
	if { ! [info exists ::window::data(tuning)] || $::window::data(tuning) ni [get-tunings]} {
	    set ::window::data(tuning) [lindex [get-tunings] 0] 
	}
	get-expanded-tuning
    }

    proc adjust {w f which {value {}} {redraw 1}} {
	
	# puts "adjust $w $f $which $value $redraw -> $::window::data($which)"
	if {$value ne {}} { set ::window::data($which) $value }
	
	# the fretboard is a rectangle of "buttons" frets wide and strings high
	# which has a tuning specified by the root note in the lower left corner
	switch $which {
	    instrument {	# the base instrument
		# puts [expand-tuning]
		# expand tuning for the instrument
		::window::adjust-all $w $f [expand-tuning] $redraw
		# redraw the controls 
		controls $w $f
	    }
	    courses {	# the number of string courses
	    }
	    multiplicity { # the number of strings in each course
	    }
	    frets {	# the number of frets on the fretboard
	    }
	    strings {	# the number of strings on the fretboard
	    }
	    root {	# the note of the open string at bottom/closest to player
	    }
	    nut {	# nut shifts the whole fretboard by semitones
	    }
	    stringnotes {	# the midi note for each string
	    }
	    tuning {	# the notes the strings are tuned to from closest to furthest
		# puts [expand-tuning]
		::window::adjust-all $w $f [expand-tuning] $redraw
	    }
	    tonic {	# the tonic is the note which is the root of the scale
	    }
	    mode {	# the mode determines which scale is labelled from the root
	    }
	    decor-highlight {
	    }
	    decor-color {
	    }
	    decor-palette {
	    }
	    decor-unmute {
	    }
	    decor-label {
	    }
	    sound {
		::sound::select $::window::data(sound)
	    }
	    default {
		error "no case for $which in adjust"
	    }
	}
	if {$redraw} { redraw $w $f }
    }

    proc adjust-all {w f keyvals {redraw 1}} {
	# puts "adjust-all $w $f {$keyvals}"
	if {[llength $keyvals] > 0} {
	    if {[llength $keyvals] > 2} {
		foreach {key value} [lrange $keyvals 0 end-2] { ::window::adjust $w $f $key $value 0 }
	    }
	    ::window::adjust $w $f {*}[lrange $keyvals end-1 end] $redraw
	}
    }
    
    proc make-button {f} {
	# first the geometry of frets and strings
	set ::window::geom(cwid) [set w [winfo width $f]]
	set ::window::geom(chgt) [set h [winfo height $f]]
	if {$w >= $h} {
	    set ::window::geom(orient) [set o {l}]
	} else {
	    set ::window::geom(orient) [set o {p}]
	}
	# ignoring the orientation, at least for now
	set ::window::geom(fper) [expr {$h/double($::window::data(frets))}]
	set ::window::geom(sper) [expr {$w/double($::window::data(courses))}]
	set ::window::geom(xper) $::window::geom(sper)
	set ::window::geom(yper) $::window::geom(fper)

	# now the geometry of the button
	set in 4
	set x0 $in
	set y0 $in
	set xm [expr {$::window::geom(xper)/2.0}]
	set ym [expr {$::window::geom(yper)/2.0}]
	set xc [expr {$::window::geom(xper)-$in}]
	set yc [expr {$::window::geom(yper)-$in}]
		
	# now build the button coordinates
	set ::window::geom(button) [list $x0 $y0 $x0 $ym $x0 $yc $xm $yc $xc $yc $xc $ym $xc $y0 $xm $y0]

	# button text coordinates
	set ::window::geom(button-text) [list $xm [expr {1.1*$ym}]]
	
	# now the font for the button label, if necessary
	if {{MyButtonFont} ni [font names]} {
	    font create MyButtonFont {*}[font configure TkHeadingFont] -size 16
	}
	set fontsize [expr {int($::window::geom(yper)/3)}]
	if {[font configure MyButtonFont -size] != $fontsize} {
	    font configure MyButtonFont -size $fontsize
	}
    }

    proc draw-button {f course fret text} {
	# get the coordinates
	foreach {x y} [fret-to-window $course $fret] break;

	# locate the button
	set xc [expr {$x+$::window::geom(xper)}]
	set yc [expr {$y+$::window::geom(yper)}]

	# draw the button
	set p [$f create polygon $::window::geom(button) -outline darkgray -fill {} -smooth true -tag $course.$fret]

	# label button
	set l [$f create text {*}$::window::geom(button-text) -text $text -anchor c -fill darkgray -font MyButtonFont -tag $course.$fret]
	
	# move them into position
	$f move $course.$fret $x $y

	# return item identifiers
	list $p $l
    }
    
    proc prepare {w f} {
	set ::window::cache [dict create]
	# iterate over chromatic degree in key to generate values
	# some of the values should be configurable in three values for tonic, scale, offs-scale
	set palette [::params::get-palette $::window::data(decor-palette)]
	set tonic [::midi::get-key $::window::data(tonic)]
	for {set cdink 0} {$cdink < 12} {incr cdink} {
	    set cdict [dict create]
	    # compute plain chromatic degree
	    dict set cdict cd [set cd [expr {($cdink+$tonic)%12}]]
	    # is-shown precomputed
	    dict set cdict is-all 1
	    dict set cdict is-none 0
	    dict set cdict is-tonic [set is-tonic [expr {$cdink == 0}]]
	    set modenotes [::midi::get-mode $::window::data(mode)]
	    dict set cdict is-scale [set is-scale [expr {[lsearch $modenotes $cdink] >= 0}]]
	    # compute label text
	    dict set cdict text [::midi::note-to-name $cd $::window::data(tonic)]
	    dict set cdict text-color  [expr {${is-tonic} ? {white} : ${is-scale} ? {lightgray} : {darkgray}}]
	    # compute button fill color
	    dict set cdict fill-color [lindex $palette $cdink]
	    # compute highlight
	    dict set cdict stroke-width [expr {${is-tonic} ? 3 : ${is-scale} ? 2 : 1}]
	    dict set cdict stroke-color [expr {${is-tonic} ? {white} : ${is-scale} ? {lightgray} : {darkgray}}]
	    # compute unmute
	    dict set cdict unmute 1
	    # save dictionary
	    dict set ::window::cache $cdink $cdict
	}
    }

    proc is-shown {cdink value} { dict get $::window::cache $cdink is-$value }

    proc redraw {w f} {
	# set inst [get-instrument]
	prepare $w $f
	make-button $f
	
	$f delete all

	# notestable will become a list of lists of lists
	# [lindex [lindex $notestable $course] $fret] will return a dictionaries
	set notestable {}

	set bangcourse [expr {$::window::data(courses)-1}]
	set bangfret [expr {$::window::data(frets)-1}]

	for {set course 0} {$course < $::window::data(courses)} {incr course} {
	    set i1 [expr {$course*$::window::data(multiplicity)}]
	    set i2 [expr {($course+1)*$::window::data(multiplicity)-1}]
	    set stringnote [lmap n [lrange $::window::data(stringnotes) $i1 $i2] {expr {$n+$::window::data(nut)}}]
	    set stringtable {}
	    for {set fret 0} {$fret < $::window::data(frets)} {incr fret} {
		# is this a posiion stolen for control shift
		set isbang [expr {$course == $bangcourse && $fret == $bangfret}]
		# initialize the notedict
		set notedict [dict create type notes course $course fret $fret]
		set fretnotes [lmap n $stringnote {expr {$n+$fret}}]
		set fretnote [lindex $fretnotes 0]
		# chromatic degree
		set cd [expr {$fretnote%12}]
		# chromatic degree in key
		set cdink [expr {($cd-[::midi::get-key $::window::data(tonic)]+12)%12}]
		# draw minimum fret decoration
		foreach {polygon label} [draw-button $f $course $fret {}] break
		# draw conditional parts
		set cdict [dict get $::window::cache $cdink]
		dict with cdict {
		    if {[is-shown $cdink $::window::data(decor-label)]} {
			$f itemconfigure $label -text $text
		    }
		    if {[is-shown $cdink $::window::data(decor-highlight)]} {
			$f itemconfigure $polygon -width ${stroke-width} -outline ${stroke-color}
			$f itemconfigure $label -fill ${text-color}
		    }
		    if {[is-shown $cdink $::window::data(decor-color)]} {
			$f itemconfigure $polygon -fill ${fill-color}
		    }
		    if {[is-shown $cdink $::window::data(decor-unmute)]} {
			dict set notedict fretnotes $fretnotes
		    }
		}
		# set the control button
		if {$isbang} {
		    $f itemconfigure $polygon -width 3 -outline white
		    $f itemconfigure $label -text {Z} -fill white
		    dict set notedict type bang
		    dict set notedict command [list ::window::controls $w $f]
		    dict set notedict fretnotes {}
		}
		lappend stringtable $notedict
	    }
	    lappend notestable $stringtable
	}
	set ::window::geom(notestable) $notestable
    }
    
    ##
    ## coordinate transformation
    ##
    
    # translate touch coordinates into the window system coordinates
    # x or wayland would do this for us, but Tk doesn't handle touch
    proc touch-to-window {x y} {
	return [list $y [expr {max(0,$::window::geom(chgt)-$x-1)}]]
    }	
    
    # translate window coordinates, x and y increasing from upper right corner
    # into string and fret
    # well, not exactly.  Translate touch input coordinates, which didn't rotate
    # with the screen when we put the touchscreen into portrait mode.
    proc touch-to-fret {x y mouse} {
	if { ! $mouse } { foreach {x y} [::window::touch-to-window $x $y] break }
	set sreal [expr {$x/$::window::geom(sper)}]
	set freal [expr {$y/$::window::geom(fper)}]
	set s [expr {max(0,min($::window::data(strings), int($sreal)))}]
	set f [expr {max(0,min($::window::data(frets), int($freal)))}]
	set sfrac [expr {$sreal-$s}]
	set ffrac [expr {$freal-$f}]
	list $s $f $sfrac $ffrac
    }
    
    # translate string and fret coordinates into window coordinates
    # in this case, they are window coordinates, and this should be
    # orientation independent
    proc fret-to-window {string fret} {
	set y [expr {$fret*$::window::geom(fper)}]
	set x [expr {$string*$::window::geom(sper)}]
	list $x $y
    }
    
    ##
    ## play the note
    ##
    proc note {action id x y} {
	foreach {string fret stringfrac fretfrac} [touch-to-fret $x $y [dict get $::params::params mouse]] break
	## puts [format "note $action $id $x $y -> %d %d %.2f %.2f" $string $fret $stringfrac $fretfrac]
	set notedict [lindex $::window::geom(notestable) $string $fret]
	if {[dict exists $notedict type]} {
	    switch [dict get $notedict type] {
		notes {
		    set i 0
		    foreach note [dict get $notedict fretnotes] {
			sound::note $action $id.[incr i] [midi::mtof $note]
		    }
		}
		bang {
		    {*}[dict get $notedict command]
		}
	    }
	}
    }
    
    ##
    ## control panel
    ##
    proc max-width {list} {
	tcl::mathfunc::max {*}[lmap i $list {string length $i}]
    }
    
    # scale as in slider for setting a numeric value
    proc myscale {w f name from to} {
	labelframe $w.$name -text [string totitle $name]
	scale $w.$name.scale -orient horizontal -showvalue true \
	    -variable ::window::data($name) -from $from -to $to \
	    -command [list ::window::adjust $w $f $name]
	pack $w.$name.scale -fill x -expand true
	return $w.$name
    }
    
    proc myoptionmenuselect {w f name} {
	# puts "myoptionmenuselect $w $f $name [$w.$name.options get] $::window::data($name)"
	$w.$name.options selection clear
	::window::adjust $w $f $name
    }
    
    proc myoptionmenu {w f name values} {
	labelframe $w.$name -text [string totitle $name]
	pack [ttk::combobox $w.$name.options -textvariable ::window::data($name) -values $values -state readonly -width [max-width $values]] -fill x -expand true
	bind $w.$name.options <<ComboboxSelected>> [list ::window::myoptionmenuselect $w $f $name]
	return $w.$name
    }
    
    proc fontsize {how} {
	if { ! [info exists ::window::geom(fontreset)]} {
	    foreach name [font names] {
		dict set ::window::geom(fontreset) $name [font configure $name -size]
	    }
	}
	foreach name [font names] {
	    set oldsize [font configure $name -size]
	    switch $how {
		smaller { set newsize [expr {$oldsize + ($oldsize>0 ? -1 : 1)}] }
		larger { set newsize [expr {$oldsize + ($oldsize>0 ? 1 : -1)}] }
		reset { set newsize [dict get $::window::geom(fontreset) $name] }
		default { error "no handler for fontsize $how" }
	    }
	    font configure $name -size $newsize
	}
    }

    proc controls {w f} {
	
	if {[winfo exists $w]} {
	    wm withdraw $w
	    $w.tuning.options configure -values [get-tunings]
	    wm deiconify $w
	} else {
	    
	    # controls
	    toplevel $w
	    
	    # choices
	    pack [myoptionmenu $w $f instrument [lsort [::instrument::get-instruments]]] -side top -fill x -expand true
	    pack [myoptionmenu $w $f tuning [get-tunings]] -side top -fill x -expand true
	    pack [myscale $w $f frets 1 36] -side top -fill x -expand true
	    pack [myscale $w $f nut -24 24] -side top -fill x -expand true
	    pack [myoptionmenu $w $f sound [lsort [::sound::list-sounds]]] -side top -fill x -expand true
	    
	    pack [myoptionmenu $w $f tonic [::midi::get-keys]] -side top -fill x -expand true
	    pack [myoptionmenu $w $f mode [::midi::get-modes]] -side top -fill x -expand true

	    foreach {name text} {decor-highlight {Highlights} decor-color {Color} decor-label {Labels} decor-unmute {Unmute}} {
		pack [labelframe $w.$name -text $text]
		foreach value [::params::get-value-list $name] {
		    pack [radiobutton $w.$name.$value -text $value -value $value -variable ::window::data($name)] -side left
		    $w.$name.$value configure -command [list ::window::adjust $w $f $name]
		}
	    }

	    # control buttons
	    pack [labelframe $w.fontsize -text {Font Size}] -side top -fill x -expand true
	    foreach name {smaller reset larger} {
		pack [button $w.$name -text [string totitle $name] -command [list ::window::fontsize $name]] -side left -fill x -expand true -in $w.fontsize
	    }
	    pack [labelframe $w.bottom -text Actions] -side top -fill x -expand true
	    pack [button $w.done -text Dismiss -command [list wm withdraw $w]] -side left -fill x -expand true -in $w.bottom
	    pack [button $w.quit -text Quit -command {destroy .}] -side left -fill x -expand true -in $w.bottom
	    pack [button $w.panic -text Panic -foreground red -command {sound::stop}] -side left -fill x -expand true -in $w.bottom
	}
    }
    
    proc main {args} {
	
	# set default values, first time
	array set ::window::data $::params::defaults
	# set values passed as arguments
	array set ::window::data  $args
	
	# expand instrument
	array set ::window::data [expand-tuning]
	
	# canvas fretboard
	pack [canvas .fretboard] -side top -fill both -expand true
	.fretboard configure -width [dict get $::params::params width] -height [dict get $::params::params height] -bg black \
	    -bd 0 -highlightthickness 0 -insertborderwidth 0 -selectborderwidth 0
	
	# bindings for window configure and control button
	bind .fretboard <Configure> {::window::redraw .zither .fretboard}
	bind .fretboard <Button-3> {::window::controls .zither .fretboard}
	
	# touch handler
	touch::init .fretboard
	
	if {[dict get $::params::params touch]} {
	    bind .fretboard <<TouchBegin>> {::window::note + %d %x %y}
	    bind .fretboard <<TouchUpdate>> {::window::note . %d %x %y}
	    bind .fretboard <<TouchEnd>> {::window::note - %d %x %y}
	}
	if {[dict get $::params::params mouse]} {
	    bind .fretboard <ButtonPress-1> {::window::note + f %x %y}
	    bind .fretboard <B1-Motion> {::window::note . f %x %y}
	    bind .fretboard <ButtonRelease-1> {::window::note - f %x %y}
	}
	
	if {[dict get $::params::params fullscreen]} {
	    after 1 {
		wm attributes . -fullscreen [dict get $::params::params fullscreen]
		# puts [winfo geometry .]
	    }
	}
    }
}
