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

`master.sh` iterates through each entry in the iTunes XML, noting important metadata and recreating the folder structure for each track. For each file in the iTunes XML, the script searches through the hexdump files created by `rescalp.sh` for matches - currently based artist, album, and track name. If a match is found `master.sh` uses file size to `dd` copy the file and place it in the recreated folder path. If the file cannot be found, a placeholder is created instead (.nf extension).

Known Issues
----
There is currently an issue causing the code to improperly asociate name data and reconstituted files.
