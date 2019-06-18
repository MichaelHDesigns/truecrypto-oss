
Debian
====================
This directory contains files used to package tdcd/tdc-qt
for Debian-based Linux systems. If you compile tdcd/tdc-qt yourself, there are some useful files here.

## tdc: URI support ##


tdc-qt.desktop  (Gnome / Open Desktop)
To install:

	sudo desktop-file-install tdc-qt.desktop
	sudo update-desktop-database

If you build yourself, you will either need to modify the paths in
the .desktop file or copy or symlink your tdcqt binary to `/usr/bin`
and the `../../share/pixmaps/tdc128.png` to `/usr/share/pixmaps`

tdc-qt.protocol (KDE)

