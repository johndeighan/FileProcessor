import {defined, LOG} from '@jdeighan/base-utils'
import {FileProcessor} from '@jdeighan/FileProcessor'

class MyFileProcessor extends FileProcessor

	begin: () ->

		@count = 0
		return

	# ..........................................................

	filterFile: (hFileInfo) ->

		return (hFileInfo.ext == '.zh')

	# ..........................................................

	beginFile: (hFileInfo) ->

		LOG "FILE: #{hFileInfo.fileName}"
		return

	# ..........................................................

	handleLine: (line, lineNum, hFileInfo) ->

		lMatches = line.match ///^
			(\**)       # leading asterisks
			\s+
			(\S+)
			///
		if defined(lMatches)
			[_, lAst, word] = lMatches
			num = lAst.length
			console.log "#{num} #{word}"
			@count += 1
			if (@count == 10)
				return {abort: true}
		return

fp = new MyFileProcessor('./test/')
fp.go()
