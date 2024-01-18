How to use this library
=======================

This library provides the object FileProcessor, which
allows you to read a file, optionally modify it,
then write it out again. If you provide a directory
path, it will process all files in that directory.

You would normally extend this class, or simply
create an object and override some of its methods.

SYNOPSIS:

```coffee
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
```

Explanation:

I have a bunch of files that contain lines like:

```text
************* 蜥蜴 xī yì - lizard
```

i.e. they start with a sequence of asterists, followed by
a space character, followed by a word in Chinese... the rest
doesn't matter. I want to print a count of the number of
asterisks, followed by the Chinese word. And, I only want
to do this for the first 10 lines found. Also, I want to
process all files in the `test` folder that have a
file extension of `.zh`.
