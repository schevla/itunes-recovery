Recover iTunes Files & Folders
====

Part of an ongoing project to recover my friend's missing files from his hard drive. Forensic techniques were required since the hard drive's partition table was shot.

Steps
----
1. Use [Scalpel 2.0](https://github.com/machn1k/Scalpel-2.0) forensics tool to find iTunes XML.
2. Once iTunes XML is recovered, this script will rebuild the folder structures and reconstitute the files.

Code
----
Ensure all environmental variables are set correctly in `master.sh` before running.

Known Issues
----
There is currently an issue causing the code to improperly asociate name data and the reconstituted file.
