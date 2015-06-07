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
  var cmdprocess:Process;
  var currentcmd:String;
  var thread:Thread;
  var processrunning:Bool;
  var compileclicked:Bool;

  var targetlist:Array<String>;
  var currenttarget:Int;
  
  var requirerestart:Bool;

  var rootdir:String;
	
  function new() {
    Gfx.resizescreen(800, 400);
    Text.changesize(16);

    targetlist = ["flash", "html5", "neko"];
    currenttarget = 0;

    processrunning = false;
    compileclicked = false;
    
    #if mac
      rootdir = Sys.getCwd();
      rootdir = Stringedit.getlastroot(rootdir, "/");
      rootdir = Stringedit.getlastroot(rootdir, "/");
      rootdir = Stringedit.getlastroot(rootdir, "/");
      rootdir = Stringedit.getlastroot(rootdir, "/");
      rootdir = rootdir + "/";
      Sys.setCwd(rootdir);
    #end
    
    Console.log("TerryCompile v0.1");
    Console.log(" ");
    if(FileSystem.exists("project.xml")){
      Console.log("[Ready]");
      requirerestart=false;
    }else{
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
	
  function update() {
    if(!requirerestart){
      /*
      if (Mouse.rightclick()) {
        if (!processrunning) {
          compileclicked = true;
          Console.log("Compiling...");
          runcommand("ls");
        }
      }
      */
      
      if (Mouse.leftclick()) {
        if (Mouse.x > 700 && Mouse.y < 20) {
          if (!processrunning) {
            compileclicked = true;
            Console.log("Compiling...");
            runcommand("openfl");
          }
        }
      }
    }

    if (Input.justpressed(Key.Q)) {
      endthread();
    }

    if(processrunning) readoutput();

    Gfx.cls(Col.NIGHTBLUE);

    Console.showlog();

    if(!compileclicked && !requirerestart){
      Gfx.fillbox(702, 2, 100, 20, Col.BLACK);
      Gfx.fillbox(700, 0, 100, 20, Col.DARKBLUE);

      Text.display(750, 0, "COMPILE", Col.WHITE, { centeralign: true } );
    }	
  }
	
  function readoutput():Void {
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

  function runcommand(cmd:String):Void {
    endthread();

    currentcmd = cmd;
    thread = Thread.create(newthread);
  }
	
  function newthread():Void {
    if(currentcmd=="openfl"){
      cmdprocess = new Process(currentcmd, ["test", targetlist[currenttarget]]);
    }else{
      cmdprocess = new Process(currentcmd, []);
    }
    processrunning = true;
  }
	
  function endthread():Void {
    if (processrunning) {
      processrunning = false;
      cmdprocess.kill();
      thread = null;
    }
  }
}