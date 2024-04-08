# Tcl package index file, version 1.1
# This file is generated by the "pkg_mkIndex" command
# and sourced either when an application starts up or
# by a "package unknown" script.  It invokes the
# "package ifneeded" command to set up package-related
# information so that packages will be loaded automatically
# in response to "package require" commands.  When this
# script is sourced, the variable $dir must contain the
# full path name of this file's directory.

package ifneeded evdev 1.0 [list source [file join $dir evdev.tcl]]
package ifneeded midi 1.0 [list source [file join $dir midi.tcl]]
package ifneeded params 1.0 [list source [file join $dir params.tcl]]
package ifneeded presets 1.0 [list source [file join $dir presets.tcl]]
package ifneeded rawtuning 1.0 [list source [file join $dir rawtuning.tcl]]
package ifneeded sound 1.0 [list source [file join $dir sound.tcl]]
package ifneeded touch 1.0 [list source [file join $dir touch.tcl]]
package ifneeded window 1.0 [list source [file join $dir window.tcl]]
