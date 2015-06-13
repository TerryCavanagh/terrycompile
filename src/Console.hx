import terrylib.*;
import terrylib.util.*;
import openfl.display.*;
import openfl.geom.*;
import openfl.events.*;
import openfl.net.*;
import openfl.text.*;
import openfl.Assets;
import openfl.Lib;
import openfl.system.Capabilities;

class Console {
	/** Clear the buffer */
	public static function clearlog():Void {
		consolelog = new Array<String>();
	}
	
	/** Outputs a string to the screen for testing. */
	public static function log(t:Dynamic, col:Int = 0xFFFFFF):Void {
		if (consolelog.length > 0) {
			if (consolelog[consolelog.length - 1].toUpperCase() == "[Ready]".toUpperCase()) {
				consolelog.pop();
				logcol.pop();
			}
		}
		
		var tempstring:String;
		tempstring = Convert.tostring(t);
		if (Text.len(tempstring) > Gfx.screenwidth) {
		  var string1:String = "";
			var string2:String = "";
			for (i in 0 ... tempstring.length) {
				if(Text.len(string1) <  Gfx.screenwidth){
					string1 = string1 + Stringedit.letterat(tempstring, i);
				}else {
					string2 = string2 + Stringedit.letterat(tempstring, i);
				}
			}
			
			log(string1, col);
			log(string2, col);
			return;
		}
		
		consolelog.push(tempstring);
		logcol.push(col);
		showtest = true;
	}
	
	/** Shows a single test string. */
	public static function test(t:Dynamic, col:Int = 0xFFFFFF):Void {
		consolelog[0] = Convert.tostring(t);
		logcol[0] = col;
		showtest = true;
	}
	
	public static function showlog():Void {
		if (showtest) {
			logposition = consolelog.length - 15;
			for (k in 0 ... consolelog.length) {
				Text.display(2, Std.int(2 + ((k-logposition) * (Text.height() + 2))), consolelog[k], logcol[k]);
			}
		}
	}
	
	public static var logposition:Int;
	public static var showtest:Bool;
	public static var consolelog:Array<String> = new Array<String>();
	public static var logcol:Array<Int> = new Array<Int>();
}