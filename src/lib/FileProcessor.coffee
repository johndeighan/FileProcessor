# FileProcessor.coffee

import {
	undef, defined, notdefined, getOptions,
	isString, isHash,
	} from '@jdeighan/base-utils'
import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {
	mkpath, pathType, parseSource, allFilesIn, allLinesIn,
	} from '@jdeighan/base-utils/fs'
import {
	dbgEnter, dbgReturn, dbg,
	} from '@jdeighan/base-utils/debug'

# ---------------------------------------------------------------------------

export class FileProcessor

	constructor: (@path, hOptions={}) ->
		# --- path can be a file or directory
		# --- Valid options:
		#        recursive

		dbgEnter 'FileProcessor', hOptions
		assert isString(@path), "path not a string"
		@hOptions = getOptions hOptions, {
			recursive: true
			}

		# --- determine type of path
		@pathType = pathType @path
		assert (@pathType == 'dir') || (@pathType == 'file'),
			"path type #{@pathType} must be dir or file"

		# --- convert path to a full path
		@path = mkpath @path
		dbgReturn 'FileProcessor'

	# ..........................................................
	# --- called at beginning of @go()

	begin: () ->

		dbg "begin() called"
		return

	# ..........................................................
	# --- called at end of @go()

	end: () ->

		dbg "end() called"
		return

	# ..........................................................

	filterFile: (hFileInfo) ->

		return true    # by default, handle all files in dir

	# ..........................................................

	filterLine: (line, lineNum, hFileInfo) ->

		return true    # by default, handle all lines in file

	# ..........................................................

	go: () ->

		@begin()
		count = 0

		switch @pathType
			when 'file'
				hFileInfo = parseSource(@path)
				name = hFileInfo.fileName
				count = 1
				if @filterFile hFileInfo
					dbg "[#{count}] #{name} - Handle"
					@handleFile hFileInfo
				else
					dbg "[#{count}] #{name} - Skip"
			when 'dir'
				dbg "process all files in '#{@path}'"
				hOpt = {recursive: !!@hOptions.recursive}
				for hFileInfo from allFilesIn(@path, hOpt)
					name = hFileInfo.fileName
					count += 1
					if @filterFile hFileInfo
						dbg "[#{count}] #{name} - Handle"
						@handleFile hFileInfo
					else
						dbg "[#{count}] #{name} - Skip"
		dbg "#{count} files processed"
		@end()
		return

	# ..........................................................

	beginFile: (hFileInfo) ->

		return    # by default, does nothing

	# ..........................................................

	procFile: (hFileInfo) ->

		assert defined(hFileInfo), "procFile(): hFileInfo = undef"
		lineNum = 1
		for line from allLinesIn(hFileInfo.filePath)
			if @filterLine line, lineNum, hFileInfo
				hResult = @handleLine line, lineNum, hFileInfo
				if defined(hResult)
					assert isHash(hResult), "handleLine() return not a hash"
					if hResult.abort
						return
			lineNum += 1
		return

	# ..........................................................

	endFile: (hFileInfo) ->

		return   # by default, does nothing

	# ..........................................................
	# --- default handleFile() calls handleLine() for each line

	handleFile: (hFileInfo) ->

		@beginFile hFileInfo
		@procFile hFileInfo
		@endFile hFileInfo
		return

	# ..........................................................

	handleLine: (line, lineNum, hFileInfo) ->

		return   # by default, does nothing
