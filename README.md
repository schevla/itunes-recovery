iTunes File & Folder Recovery
====

This is part of an ongoing project to recover a friend's missing files from a hard drive. Forensic techniques were required since the hard drive's partition table was non-existant.

Steps
----
1. Use [Scalpel 2.0](https://github.com/machn1k/Scalpel-2.0) forensics tool to find iTunes XML.
2. `rescalp.sh` can be used to "rescalp" files from `audit.txt` with a specified size. This is useful for hexdumps or other operations that need to be performed quickly to analyze `audit.txt` results without having to sift through very large files.
3. Once iTunes XML is recovered, `master.sh` will rebuild the folder structures and reconstitute the files.

Code
----
Ensure all environmental variables are set correctly in `master.sh` **and** that all files used in the script are located in the right locations before running. This involves the audit file from the Scalpel 2.0 script.

Known Issues
----
There is currently an issue causing the code to improperly asociate name data and reconstituted files.
