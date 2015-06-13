import terrylib.*;
import haxe.io.Output;
import sys.io.Process;
import haxe.io.Eof;
import sys.FileSystem;
#if cpp
  import cpp.vm.Thread;
#elseif neko
  import neko.vm.Thread;
#end

class Main {
	public static var testmode:Bool = false; // Show GUI controls even if we're not in a TerryLib dir.
	
  public static var cmdprocess:Process;
  public static var currentcmd:String;
  public static var thread:Thread;
  public static var processrunning:Bool;
  public static var compileclicked:Bool;
	public static var version:String;

  public static var targetlist:Array<String>;
  public static var currenttarget:Int;
  
  public static var buildlist:Array<String>;
  public static var buildcommand:Array<String>;
  public static var currentbuild:Int;
	
  public static var requirerestart:Bool;

  public static var rootdir:String;
	
  public function new() {
    Gfx.resizescreen(800, 300);
    Text.changesize(16);
		
		version = "v1.0";
    buildlist = ["normal", "final"];
		buildcommand = ["test", "build"];
    targetlist = ["flash", "html5", "neko"];
    #if mac
		targetlist.push("mac");
		#elseif windows
		targetlist.push("windows");
		#elseif linux
		targetlist.push("linux");
		#end
    currenttarget = 0;
		currentbuild = 0;
		
    processrunning = false;
    compileclicked = false;
    
		Gui.init();
		
    #if mac
      rootdir = Sys.getCwd();
      rootdir = Stringedit.getlastroot(rootdir, "/");
      rootdir = Stringedit.getlastroot(rootdir, "/");
      rootdir = Stringedit.getlastroot(rootdir, "/");
      rootdir = Stringedit.getlastroot(rootdir, "/");
      rootdir = rootdir + "/";
      Sys.setCwd(rootdir);
    #end
    
    Console.log("TerryCompile " + version);
    if(FileSystem.exists("project.xml") || testmode){
      Console.log("Click the COMPILE button in the top right to compile!");
      Console.log(" ");
      Console.log("[Ready]");
      requirerestart = false;
			
			Gui.addbutton(695, 6, 100, "COMPILE", "compile");
			Gui.adddroplist(570, 4, 100, "target");
			Gui.adddropdown(655, 6);
			//Gui.adddroplist(455, 4, 100, "build");
			//Gui.adddropdown(540, 6);
    }else{
      Console.log(" ");
      Console.log("HOW TO USE THIS UTILITY:");
      #if mac
        Console.log("Copy this app into the project folder that you want to compile, and restart.");
      #else
        Console.log("Copy this program into the project folder that you want to compile, and restart.");
      #end
      Console.log("(i.e. the folder containing the project.xml file.)");
      requirerestart=true;
    }
  }
	
  public static function update() {
    if(!requirerestart){
      Gui.checkinput();
    }
		
    if (Input.justpressed(Key.Q)) {
      endthread();
    }
		
    if (processrunning) readoutput();
		
    Gfx.cls(Col.NIGHTBLUE);
		
    Console.showlog();
		if (!requirerestart) {
			Gfx.fillbox(0, 0, Gfx.screenwidth, 30, 0xFF3B4652);
			
			Text.display(4, 4, "TerryCompile " + version, 0xDDDDDD);
			Text.display(500, 4, "TARGET:", 0xDDDDDD);
			
			Gui.drawbuttons();
		}
  }
	
  public static function readoutput():Void {
    var tempstring:String = ""; 

    try {
      tempstring = cmdprocess.stderr.readLine().toString();
    }catch (e:haxe.io.Eof) {
      try {
        tempstring = cmdprocess.stdout.readLine().toString();
      }catch (e:haxe.io.Eof) {
        Console.log(" ");
        Console.log("[Ready]");
        compileclicked = false;
        processrunning = false;
      }
    }

    if (tempstring != "") Console.log(tempstring, Col.GRAY);
  }

  public static function runcommand(cmd:String):Void {
    endthread();

    currentcmd = cmd;
    thread = Thread.create(newthread);
  }
	
  public static function newthread():Void {
    if(currentcmd=="openfl"){
      cmdprocess = new Process(currentcmd, ["test", targetlist[currenttarget]]);
    }else{
      cmdprocess = new Process(currentcmd, []);
    }
    processrunning = true;
  }
	
  public static function endthread():Void {
    if (processrunning) {
      processrunning = false;
      cmdprocess.kill();
      thread = null;
    }
  }
}