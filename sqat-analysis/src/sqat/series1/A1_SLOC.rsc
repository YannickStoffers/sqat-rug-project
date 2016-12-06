module sqat::series1::A1_SLOC

import IO;
import util::FileSystem;
import List;

/* 

Count Source Lines of Code (SLOC) per file:
- ignore comments
- ignore empty lines

Tips
- use locations with the project scheme: e.g. |project:///jpacman/...|
- functions to crawl directories can be found in util::FileSystem
- use the functions in IO to read source files

Answer the following questions:
- what is the biggest file in JPacman?
	nl.tudelft.jpacman.level.Level.java (179 LOC).
	
- what is the total size of JPacman?
	2458 SLOC. Exlcuding test code: 1901 LOC.
	
- is JPacman large according to SIG maintainability?
	No. It's a tiny project. Projects start receiving a + rating at 66 KLOC.

- what is the ratio between actual code and test code size?
	1901 : 557. Roughly 1 line of testing code per 4 lines of program code.

Sanity checks:
- write tests to ensure you are correctly skipping multi-line comments
- and to ensure that consecutive newlines are counted as one.
- compare you results to external tools sloc and/or cloc.pl

Bonus:
- write a hierarchical tree map visualization using vis::Figure and 
  vis::Render quickly see where the large files are. 
  (https://en.wikipedia.org/wiki/Treemapping) 

*/

alias SLOC = map[loc file, int sloc];

SLOC sloc(loc project) {
	SLOC result = ();
	
	if (isDirectory (project))
	{
		for (loc l <- files (project)) {
			if (l.extension == "java")
				result += (l: countSloc (l));
		}
	}
	else {
		result += (project: countSloc (project));
	}
	
	int sum = 0;
	int max = 0;
	loc largest;
	for (loc l <- result)
	{
		sum += result[l];
		if (result[l] > max)
		{
			max = result[l];
			largest = l;
		}
	}
	
	println ();
	print ("The file with the most SLOC (");
	print (max);
	println (") is:");
	println (largest);
	println ();
	print ("The total amount of SLOC is: ");
	println (sum);
	println ();
	return result;
}

int countSloc (loc file) {
	list[str] contents = readFileLines (file);
	int result = size (contents);
	bool comment = false;
	for (str line <- contents) {
		if (/^\s*\/\/.*$/ := line)
			result -= 1;
			// End of line comments spanning whole lines.
		else if (/^\s*\/\*.*\*\/\s*$/ := line)
			result -= 1;
			// Block comments spanning a single (but whole) line.
		else if (/^\s*$/ := line)
			result -= 1;
			// Whitespace lines.
		else if (/^\s*\/\*.*/ := line)
		{
			comment = true;
			result -= 1;
			// Begin of block comment.
		}
		else if (/.*\*\/\s*$/ := line)
		{
			comment = false;
			result -= 1;
			// End of block comment.
		}
		else if (/.*\/\*.*/ := line)
			comment = true;
			// Begin of block comment after statements.
		else if (/.*\*\/.*/ := line)
			comment = false;
			// End of block comment before statements.
		else
			result -= (comment ? 1 : 0);
			// Deduct a point if inside block comment.
	}
	return result;
}
