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
		@numFiles = 0
		@hNumLines = {}     # { <filePath> => <numLines>, ... }
		dbgReturn 'FileProcessor'

	# ..........................................................

	totalLines: () ->

		tot = 0
		for path in Object.keys(@hNumLines)
			tot += @hNumLines[path]
		return tot

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
	# --- default handleFile() calls handleLine() for each line

	handleFile: (hFileInfo) ->

		# --- if we're here, then filterFile() returned true
		@beginFile hFileInfo
		@procFile hFileInfo
		@endFile hFileInfo
		@numFiles += 1
		return

	# ..........................................................

	beginFile: (hFileInfo) ->

		return

	# ..........................................................

	recordNumLines: (path, numLines) ->

		@hNumLines[path] = numLines
		return

	# ..........................................................

	procFile: (hFileInfo) ->

		assert defined(hFileInfo), "procFile(): hFileInfo = undef"
		filePath = hFileInfo.filePath
		numLines = 0
		for line from allLinesIn(hFileInfo.filePath)
			numLines += 1
			if @filterLine line, numLines+1, hFileInfo
				hResult = @handleLine line, numLines+1, hFileInfo
				if defined(hResult)
					assert isHash(hResult), "handleLine() return not a hash"
					if hResult.abort
						@recordNumLines filePath, numLines
						return
		@recordNumLines filePath, numLines
		return

	# ..........................................................

	endFile: (hFileInfo) ->

		return   # by default, does nothing

	# ..........................................................

	filterLine: (line, lineNum, hFileInfo) ->

		return true    # by default, handle all lines in file

	# ..........................................................

	handleLine: (line, lineNum, hFileInfo) ->

		# --- if we're here, then filterLine() returned true
		return   # by default, does nothing

