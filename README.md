# Nautilus Bridge Tools

A handy collection of scripts for Nautilus' file context menu.

## Table of Contents

1. [Installation](#installation)
2. [Scripts](#scripts)

    1. [open-parent-in-terminal](#open-parent-in-terminal)
    2. [share-with-nextcloud](#share-with-nextcloud)
    3. [virustotal-scan](#virustotal-scan)

![nautilus-bridge-tools-screenshot](https://github.com/theCalcaholic/nautilus-bridge-tools/releases/download/doc-assets/nautilus-bridge-tools-screenshot.png)

## Scripts

### open-parent-in-terminal

Nautilus has an annoying design flaw: When you are in list view and there are enough files in your directory that can be displayed at once (so you get a scrollbar), there is no way to get the current directory's context menu (that you get when right clicking empty space in a directory).
One of the functions from that context menu that I need most is the "Open in Terminal" option. Therefore, I added a script that allows you to open a terminal in any file's parent directory's location.

### share-with-nextcloud

This script let's you create a public Nextcloud share from a local file. Quick and easy! It does so by uploading the file to a special directory in your nextcloud (/nautilus-share) and creating a public share link for it. For your convenience that link will then be opened in your browser.

### virustotal-scan

I do not use a local antivirus tool on my computer. However, every now and then I need to work with a file that I don't fully trust. That's where Virustotal comes in. It is a web service which allows you to upload and scan a file with a total of 60 popular malware detection tools. Because I'm lazy, I didn't want to open up the web page every time I use the service, so I wrote a nautilus integration script. Shortly after executing it on a file, it will open the virustotal page with its scan results.

## Installation

The easiest way is by using git:

```sh
mkdir -p ~/.local/share/nautilus/scripts
cd ~/.local/share/nautilus/scripts
git clone git@github.com:theCalcaholic/nautilus-bridge-tools.git bridge-tools
```

You should find the scripts under Scripts -> bridge-tools if you right-click a file in Nautilus.

