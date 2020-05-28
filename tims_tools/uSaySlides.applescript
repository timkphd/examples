-- ****** sayslides ******
-- ********** Frist usage:
-- Script to "read" the contents of 
-- Keynote presentation presenter notes
-- and either say them or save them to
-- a file.
--
-- If you save the presenter notes to a 
-- file you also get a shell script "runme" 
-- that will convert the text to audio files.
-- You should source runme to create
-- audio files.
--
-- ********** Second usage:
-- This script can be used to import
-- audio files back into Keynote. That 
-- is to paste a collection of Audio clips
-- into a Keynote presentation.  These
-- can be any audio clips. However
-- the most common usage is to first
-- use this script to export the presenter
-- notes to files.  You then source the
-- shell script "runme" that is created to
-- create audio files.  Finally you then 
-- use this script to paste the audio 
-- files back into  the Keynote presentation.
--
--
-- Author:
-- Timothy H. Kaiser, Ph.D.
-- Colorado School of Mines
-- Sep 22, 2014.
--
-- Based on information from
-- http://iworkautomation.com/keynote/media-items-audio-clip.html

property narrator_voice : "Tom"
set mygo to true
repeat while mygo
	global rate_tag, current_voice, current_system_voice, save_text, say_text, doit
	--set r to text returned of (display dialog "What is your name" default answer "" buttons {"OK"} default button "OK")
	set dohelp to false
	set save_text to false
	set say_text to false
	set runit to false
	set doit to false
	set pasteit to false
	set cutit to false
	--set theAction to choose from list {"Help", "Speak Text", "Save Text", "Both", "Make Audio", "Get Audio", "Cut Audio"} with prompt "Action:"
	set theAction to choose from list {"Help", "Speak Text", "Save Text", "Make Audio", "Get Audio", "Cut Audio"} with prompt "Action:"
	if theAction is false then
		set mygo to false
	end if
	if (theAction as string = "Help" as string) then
		set dohelp to true
	end if
	if (theAction as string = "Make Audio" as string) then
		set runit to true
	end if
	if (theAction as string = "Cut Audio" as string) then
		set cutit to true
	end if
	if (theAction as string = "Get Audio" as string) then
		set pasteit to true
		set doit to false
	end if
	if ((theAction as string = "Speak Text" as string) or (theAction as string = "Both" as string)) then
		set say_text to true
		set doit to true
	end if
	if ((theAction as string = "Save Text" as string) or (theAction as string = "Both" as string)) then
		set save_text to true
		set doit to true
		--set dfold to alias "Users:Shared:slides"
		set dfold to path to home folder
		set fold to choose folder with prompt ("Location for Slide Text:") default location dfold
		set fold to fold as string
	end if
	if runit then
		try
			set dfold to path to home folder
			set fold to choose folder with prompt ("Folder Containing Slide Text:") default location dfold
			set fold to fold as string
			set fname to fold & "runme"
			set myout to do shell script "cd  " & quoted form of POSIX path of fold & ";" & quoted form of POSIX path of fname
			--display notification myout with title "Text Files Processed:"
			display alert "Text Files Processed:" message myout giving up after 7
		on error
			display alert "Processing Files failed. Check that you have a \"runme\" file in the choosen directory"
		end try
		
	end if
	if doit then
		set current_voice to narrator_voice
		tell application "Keynote"
			activate
			start slideshow
			--		tell slide 1
			--			show slide 1
			set k to 0
			set these_slides to slide of the front document
			set slide_count to count of these_slides
			set the starting_slide_index to 1
			repeat with i from starting_slide_index to the slide_count
				set aslide to item i of these_slides
				if skipped of aslide is false then
					set bonk to presenter notes of aslide
					if say_text is true then
						say bonk using current_voice
					end if
					if save_text is true then
						set k to k + 1
						set ks to k as string
						set ks to text -4 thru -1 of ("0000" & k)
						set fname to fold & ks
						my write_file(fname, bonk, true)
						set cname to fname & ".aiff"
					end if
				end if
				try
					show next
				end try
				
			end repeat
			
			-- cut section		
			if save_text is true then
				set bonk to "#!/bin/bash" & linefeed & "rm *aac *aiff; slides=`ls 0*`"
				set bonk to bonk & " ; "
				set bonk to bonk & "for s in $slides ; do echo $s ; cat $s | say -o $s.aiff -f -  ;done"
				set fname to fold & "runme"
				my write_file(fname, bonk, true)
				do shell script "chmod  700 " & quoted form of POSIX path of fname
			end if
		end tell
		if save_text is true then
			tell application "Keynote"
				try
					stop slideshow
				end try
			end tell
			set mem to "Please go to " & fold & " and execute the file runme"
			--say mem
			display alert mem
		end if
	end if
	
	if cutit then
		tell application "Keynote"
			activate
			
			try
				set these_slides to slide of the front document
				set slide_count to count of these_slides
				--				display dialog "Looking for Audio in " & slide_count & " slides"
				set the starting_slide_index to 1
				tell document 1
					repeat with i from starting_slide_index to the slide_count
						
						set aslide to item i of these_slides
						--display dialog i
						--delay 0.1
						
						start slideshow
						show aslide
						stop slideshow
						
						try
							set things to audio clips of aslide
							set coft to (count of things)
							--if (count of things) is greater than 0 then
							--	display dialog " inside try " & i & " " & coft
							--end if
							-- set ithings to (count of things)
							--display dialog i & " ithings " & coft
							if coft is greater than 0 then
								--display dialog "coft > 0"
								
								repeat with kb from 1 to the coft
									set k to (coft - kb) + 1
									--repeat with theItem in things
									--display dialog k
									
									set theItem to item k of things
									tell theItem
										set locked to false
										set bonk to get position as text
										--display dialog "delete"
										if bonk is "55" then
											delete theItem
										end if
									end tell
								end repeat
							end if
							--delete audio clips of aslide
							
						end try
					end repeat
				end tell
			end try
		end tell
		
	end if
	if dohelp then
		tell application "Safari"
			open location "http://geco.mines.edu/uSaySlides/"
			activate
		end tell
	end if
	
	if pasteit then
		-- ****** pasteit ******
		-- Script to paste a collection of Audio
		-- clips into a Keynote presentation.  
		-- This is designed to be used with The
		-- sayslides script.  You use sayslides to
		-- export the presenter notes to files and
		-- then run the shell script that is created
		-- to create audio files.  You then use this
		-- script to paste the audio files back into
		-- the Keynote presentation.
		--
		--
		-- Author:
		-- Timothy H. Kaiser, Ph.D.
		-- Colorado School of Mines
		-- Sep 16, 2014.
		--
		-- Based on information from
		-- http://iworkautomation.com/keynote/media-items-audio-clip.html
		
		tell application "Keynote"
			activate
			try
				-- PROMPT USER TO PICK AUDIO FILE
				--set dfold to alias "Users:Shared:slides"
				set dfold to path to home folder
				set fold to choose folder with prompt ("Location for Slide Text:") default location dfold
				set fold to fold as string
				set these_slides to slide of the front document
				set slide_count to count of these_slides
				set the starting_slide_index to 1
				set k to 0
				tell document 1
					-- IMPORT AUDIO FILE TO CURRENT SLIDE
					repeat with i from starting_slide_index to the slide_count
						set aslide to item i of these_slides
						if skipped of aslide is false then
							tell aslide
								-- Keynote does not support using the audio clip class with the make verb
								-- Import the audio file by using the image class as the direct parameter
								-- The returned object reference will be to the created audio file
								set k to k + 1
								set ks to k as string
								set ks to text -4 thru -1 of ("0000" & k)
								set fname to fold & ks
								set cname to fname & ".aiff"
								--display dialog "calling thisAudioClip"
								set thisAudioClip to make new image with properties {file:cname}
								--display dialog "did thisAudioClip"
								
								-- ADJUST AUDIO CLIP PROPERTIES
								tell thisAudioClip
									-- position property inherited from iWork Item class
									set position to {5, 5}
									-- audio clip properties
									set clip volume to 75
									--set repetition method to loop
									-- place the locked property at the end because
									-- you can't change the properties of a locked iWork item
									--set locked to true
									
								end tell
							end tell
						end if
					end repeat
				end tell
			on error errorMessage number errorNumber
				if errorNumber is not -128 then
					display alert ("ERROR " & errorNumber as string) message errorMessage
				end if
			end try
		end tell
	end if
end repeat
on write_file(the_file, the_info, overwrite_contents)
	--say the_file
	try
		close access the_file
	end try
	set opened_file to open for access the_file with write permission
	if overwrite_contents is true then set eof of opened_file to 0
	--write ((ASCII character 254) & (ASCII character 255)) to opened_file starting at eof
	write the_info to opened_file starting at eof as Çclass utf8È
	close access opened_file
end write_file
