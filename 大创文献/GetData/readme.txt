License
=======

    GetData Graph Digitizer 2.25
    SOFTWARE LICENSE AGREEMENT

    GetData Graph Digitizer is distributed as try-before-you-buy 
    software. Anyone may use this software during a test period 
    of 21 days. Following this test period or less, if you wish to
    continue to use GetData Graph Digitizer, you must register.

    The GetData Graph Digitizer unregistered shareware version may 
    be freely distributed, provided the distribution package is not
    modified. No person or company may charge a fee for the
    distribution of GetData Graph Digitizer without written permission 
    from the author.

    THIS SOFTWARE IS PROVIDED "AS IS". NO WARRANTY OF ANY KIND
    IS EXPRESSED OR IMPLIED. IN NO EVENT WILL THE AUTHOR BE
    LIABLE FOR DATA LOSS, DAMAGES, LOSS OF PROFITS OR ANY OTHER
    KIND OF LOSS WHILE USING OR MISUSING THIS SOFTWARE.

    Installing and using GetData Graph Digitizer signifies acceptance 
    of these terms and conditions of the license.


Copyright
=========

Expat XML parser: http://www.libexpat.org/
  Copyright (c) 1998, 1999, 2000 Thai Open Source Software Center Ltd and Clark Cooper
  Copyright (c) 2001, 2002 Expat maintainers

IJG JPEG library: http://www.ijg.org/
  Copyright (c) 1991-1998, Thomas G. Lane.

LibTIFF Software: http://www.remotesensing.org/libtiff/
  Copyright (c) 1994-1997 Sam Leffler
  Copyright (c) 1994-1997 Silicon Graphics, Inc.

CProgressBar class
  Copyright (c) 1998 Chris Maunder

CMenuXP class
  Copyright (c) Jean-Michel LE FOL

CSizingControlBar class
  Copyright (c) 1998-2002 Cristi Posea

MFC Grid Control
  Copyright (c) 1998-2002 Chris Maunder



What's new
==========
Version 2.25, 18.08.2012
  Fixed: writing to a workspace file, bug 

Version 2.24, 26.03.2008
  Fixed: minor bugs

Version 2.23, 11.02.2008
  Fixed: memory usage is optimized for large images

Version 2.22, 05.02.2006
  Added: grid (View=>Show grid) can now be related to the axes
  Added: "Adjust the scale" button added to the information window
  Added: image is panned when holding down middle mouse button (the wheel)
  Changed: Ctrl+A selects all data points in the Data tab
  Fixed: Several minor bugs

Version 2.21, 11.04.2005
  Changed: line/background identification algorithm improved

Version 2.20, 18.01.2005
  Fixed: export to EPS format, minor bug

Version 2.19, 12.01.2005
  Added: list of recently opened files in the File menu
  Changed: zoom in/out follows cursor in Point capture mode
  Changed: mouse scroll now changes zoom; image moves around when holding left mouse button
  Added: Operations=>Set default axes
  Added: in Point capture mode data points can be selected with right mouse button and moved to a new location
  Added: when data points are selected in the Data tab corresponding points are shown in the main window
  Fixed: in the reorder tool mode Ctrl allows to skip any part of data points, not the beginning of line only 

Version 2.18, 12.10.2004
  Added: "Settings=>Options=>Digitize area=>Data points are placed ..." option
  Added: File=>Close
  Fixed: minor bug (on some computers mouse pointer moved slightly when pressing Ctrl)

Version 2.17, 18.06.2004
  Fixed: zoom in/zoom out behaviour in some modes

Version 2.16, 25.05.2004
  Added: export to XLS and XML files

Version 2.15, 14.05.2004 
  Added: TIFF format support
  Changed: more complete JPEG support
  Added: grid (Operations=>Digitize area) can be moved when holding Ctrl
  Added: option to search for the image file, if it is not found when opening workspace

Version 2.14, 02.04.2004
  Added: Ctrl in Point capture mode allows for more accurate cursor positioning
  Changed: first point is marked out (enlarged) in the reorder tool mode
  Added: different line types
  Added: export to EPS files 
  Added: "Settings=>Options=>Digitize=>Smooth lines" option

Version 2.12, 12.03.2004
  Added: export to AutoCAD DXF format ("File=>Export to DXF file")
  Added: "Settings=>Options=>Digitize=>Line/background identification method" option

Version 2.11, 03.03.2004
  Added: "View=>Connect points"
  Added: Reorder tool

Version 2.10, 18.02.2004
  Added: rectangular grid (Operations=>Digitize area) can be rotated when holding Shift
  Added: multiple lines supported

Version 2.04, 03.02.2004
  Fixed: problem with non-english filenames
  Added: unicode support
  Changed: resizable information window

Version 2.03, 23.01.2004
  Added: Mathematica output format ("Settings=>Options=>Export ...")

Version 2.02, 07.01.2004
  Added: axes OX and OY are drawn
  Fixed: minor bugs

Version 2.01, 24.12.2003
  Added: "Set the scale" button
  Added: "Operations=>Set line color"
  Added: "Operations=>Set background color"
  Added: "Auto trace lines" button
  Added: "Operations=>Digitize area" feature & "Digitize area" button
  Added: "Ignore single pixels/very thin lines" option in the "Digitize" options
  Added: Undo feature

Version 1.19, 02.11.2003
  Added: *.gdw is associated with GetData
  Added: file name in the window caption
  Fixed: minor bugs
  Added: "Data" tab with X,Y data in the Information window
  Added: "Save Workspace As..." in the "File" menu

Version 1.18.2, 03.10.2003
  Fixed: bug under Windows 98/ME (unstable work)

Version 1.18, 30.09.2003
  Fixed: Several minor bugs
  Added: "Point capture mode"
  Changed: hot keys added
  Changed: cursor color in eraser and point capture modes is inverted when cursor is over dark areas

Version 1.17.2, 14.09.2003
  Changed: Ctrl+double click replaced with Shift+click left mouse button

Version 1.17, 08.09.2003
  Fixed: Several minor bugs
  Added: "Show image" button (show/hide image feature)
  Added: "Show grid" button (show/hide grid feature)
  Added: Tips

Version 1.16.2, 12.08.2003
  Changed: X-value based sorting of data points made optional

Version 1.16, 28.06.2003
  Changed: docking magnifier and information windows
  Fixed: support of JPG files created by Adobe Photoshop
  Added: "Copy data to buffer" function
  Changed: Settings=>Options dialog

Version 1.15, 01.02.2003
  Added: Open/Save workspace (in XML format)
  Added: Multilingual interface (English, Russian)
  Added: "AutoTrace=>Choose direction" feature
  Added: "Operations=>Acquire line and background colors"
  Added: 16 colors BMP format support
  Changed: Improved interface (magnifier and information as separate windows)
  Improved: Export to text file, "0.001" format
  Fixed: Several minor bugs
