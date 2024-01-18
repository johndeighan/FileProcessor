# FileProcessor.test.coffee

import {defined, LOG} from '@jdeighan/base-utils'
import {utest} from '@jdeighan/base-utils/utest'
import {FileProcessor} from '@jdeighan/FileProcessor'

# ---------------------------------------------------------------------------

class MyFileProcessor extends FileProcessor

	begin: () ->

		@lLines = []   # collect output lines here
		return

	# ..........................................................

	filterFile: (hFileInfo) ->

		return (hFileInfo.ext == '.zh') && (@lLines.length < 10)

	# ..........................................................

	filterLine: (hFileInfo) ->

		return (@lLines.length < 10)

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
			@lLines.push "#{num} #{word}"
			if (@lLines.length == 10)
				return {abort: true}
		return

fp = new MyFileProcessor('./test/')
fp.go()

utest.equal 42, fp.lLines.length, 10
utest.equal 43, fp.numFiles, 2
utest.equal 44, fp.totalLines(), 10
