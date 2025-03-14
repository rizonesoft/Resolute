Folder for custom import modules, for converting forms from other formats to Koda form. 
This can be autoit script (.au3, .a3x) or executable file. Result XML data should be sent by module via StdOut.

Some special strings are can appear in the output stream. They are in regular XML comments format, so will not affect xml stream.

<!--DESCR:Module description-->
This string returned when module called with /info parameter, it can contain description of your converter. You may omit this, but in any case module *should* return immediately when /info parameter passed.

For import Koda have four debug output levels: error, warning, info, debug. They are shown in debug window with corresponding colors. All those messages can be placed in output stream.

<!--ERROR:Description-->
If your module encounter a problem in input file and should break conversion process, return this string with error description.

<!--WARNING:Description-->
If your module encounter a non-critical problem, return this string with description.

<!--INFO:Description-->
Any other standard info, that may be useful. 

<!--DEBUG:Description-->
Some detailed info about process. Instead previous 3 levels, not show with default Koda settings.


Output format:
You can create one of two types of XML data. 
1. First - "finished" data, with required object tree structure. Refer Koda XML format for details.
2. Second - "simplified" intermediate format. You need only write info about objects as properties, final job (tree structuring etc) Koda will do itself. Append level="1" property to the form node in this case.

Example of simplified format:
<object type="TAForm" level="1" name="FormName">
  <object type="TAButton" Name="Button1" Width="80" Height="24" Caption="My Button" CtrlStyle="1342242816">
</object>

Note, all 32-bit integers should be *signed* type!