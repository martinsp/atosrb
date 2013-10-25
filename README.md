# atosrb: a wraper for 'atos' command to symbolicate OS X application crashlogs 

This utility will parse a crashlog and symbolicate it with `atos` utility.

## usage
		atosrb application.app crashlog.crash
* application.app.dSYM file is required to be in the same directory as application.app file for 'atos' command to symbolicate crashlogs
* atosrb accepts multiple paths/directories as arguments. If directory is passed, atosrb will look for *.crash files in that directory and process them

## installation
		git clone https://github.com/martinsp/atosrb.git
		cd atosrb
		gem build atosrb.gemspec
		gem install atosrb-x.x.x.gem
 