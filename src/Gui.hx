import flash.display.*;
import flash.geom.*;
import flash.events.*;
import flash.utils.*;
import flash.net.*;
import terrylib.*;
	
class Gui {
	public function new() {}
	
	public static function init():Void {
		for(i in 0 ... 250){
			button.push(new Guibutton());
		}
		
		numbuttons = 0;
		maxbuttons = 250;
		
		listopen = false;
	}
	
	public static function addbutton(x:Int, y:Int, w:Int, text:String, action:String, textoffset:Int = 0):Void {
		addguipart(x, y, w, 20, text, action, "normal", textoffset);
	}
	
	public static function adddropdown(x:Int, y:Int):Void {
		addguipart(x, y, 20, 20, "", "", "downarrow", 0);
	}
	
	public static function adddroplist(x:Int, y:Int, w:Int, action:String):Void {
		addguipart(x, y, w, 20, "", action, "droplist", 0);
	}
	
	public static function addlist(x:Int, y:Int, w:Int, action:String):Void {
		if(action == "buildtarget"){
			addguipart(x, y, w, Main.targetlist.length * 20, "", action, "buildtarget", 0);
		}else if(action == "buildbuild"){
			addguipart(x, y, w, Main.buildlist.length * 20, "", action, "buildbuild", 0);
		}
	}
	
	public static function addguipart(x:Int, y:Int, w:Int, h:Int, contents:String, act:String = "", sty:String = "normal", toffset:Int = 0):Void {
		if (button.length == 0) init();
		
		var i:Int, z:Int;
		if(numbuttons == 0) {
			//If there are no active buttons, Z=0;
			z = 0; 
		}else {
			i = 0; z = -1;
			while (i < numbuttons) {
				if (!button[i].active) {
					z = i; i = numbuttons;
				}
				i++;
			}
			if (z == -1) {
				z = numbuttons;
			}
		}
		//trace("addguipart(", x, y, w, h, contents, act, sty, ")", numbuttons);
		button[z].init(x, y, w, h, contents, act, sty);
		button[z].textoffset = toffset;
		if (sty == "horizontalslider") {
			button[z].moveable = true;
		}
		numbuttons++;
	}
	
	public static function clear():Void {
		for(i in 0 ... numbuttons){
			button[i].active = false;
		}
		numbuttons = 0;
	}
	
	public static function buttonexists(t:String):Bool {
		//Return true if there is an active button with action t
		for(i in 0 ... numbuttons){
			if (button[i].active) {
				if (button[i].action == t) {
					return true;
				}
			}
		}
		
		return false;
	}
	
	
	public static function inboxw(xc:Float, yc:Float, x1:Float, y1:Float, x2:Float, y2:Float):Bool {
		if (xc >= x1 && xc <= x1+x2) {
			if (yc >= y1 && yc <= y1+y2) {
				return true;
			}
		}
		return false;
	}
	
	public static function checkinput():Void {
		for(i in 0 ... numbuttons){
			if (button[i].active && button[i].visable) {
				if (inboxw(Mouse.x, Mouse.y, button[i].position.x, button[i].position.y, button[i].position.width, button[i].position.height)) {
					button[i].mouseover = true;
				}else {
					button[i].mouseover = false;
				}
				
				if (button[i].action != "") {
					if (button[i].moveable) {
						if (Mouse.leftheld()) {
							dobuttonmoveaction(i);
						}
					}else	if (button[i].mouseover) {
						if (Mouse.leftclick()) {
							dobuttonaction(i);
						}
					}
				}
			}
		}
		
		cleanup();
	}
	
	public static function cleanup():Void {
		var i:Int = 0;
		i = numbuttons - 1; while (i >= 0 && !button[i].active) { numbuttons--; i--; }
	}
	
	public static function drawbuttons():Void {
		for (i in 0 ... numbuttons) {
			if (button[i].active && button[i].visable) {
				if (button[i].style == "normal") {
					Gfx.fillbox(button[i].position.x, button[i].position.y, button[i].position.width, button[i].position.height, Col.BLACK);
					if (button[i].pressed > 0) {
						button[i].pressed--;
						if (button[i].pressed < 2) {
							timage = 1;
						}else{
							timage = 0;
						}
					}else{
						timage = 2;
					}
					
					if (button[i].text == "CANCEL") {
						if (button[i].mouseover) {
							Gfx.fillbox(button[i].position.x - timage, button[i].position.y - timage, button[i].position.width, button[i].position.height, 0xFFFF7731);
						}else {
							Gfx.fillbox(button[i].position.x - timage, button[i].position.y - timage, button[i].position.width, button[i].position.height, 0xFFF25531);
						}
					}else{
						if (button[i].mouseover) {
							Gfx.fillbox(button[i].position.x - timage, button[i].position.y - timage, button[i].position.width, button[i].position.height, 0xFF3177FF);
						}else {
							Gfx.fillbox(button[i].position.x - timage, button[i].position.y - timage, button[i].position.width, button[i].position.height, 0xFF3155F2);
						}
					}
					
					tx = button[i].position.x - 2 + (button[i].position.width / 2) - (Text.len(button[i].text) / 2) + button[i].textoffset - timage;
					ty = button[i].position.y - 1 - timage;
					
					Text.display(tx + 1, ty + 1, button[i].text, Col.BLACK);
					Text.display(tx, ty, button[i].text, Col.WHITE);
				}else if (button[i].style == "downarrow") {
					tx = button[i].position.x;
					ty = button[i].position.y + 6;
					Gfx.fillbox(tx+0, ty+0, 10, 1, Col.WHITE);
					Gfx.fillbox(tx+1, ty+1, 8, 1, Col.WHITE);
					Gfx.fillbox(tx+2, ty+2, 6, 1, Col.WHITE);
					Gfx.fillbox(tx+3, ty+3, 4, 1, Col.WHITE);
					Gfx.fillbox(tx+4, ty+4, 2, 1, Col.WHITE);
				}else if (button[i].style == "droplist") {
					tx = button[i].position.x;
					ty = button[i].position.y;
					
					if (button[i].mouseover) {
						Gfx.fillbox(tx, ty, button[i].position.width, button[i].position.height, 0xFF2B3642);
					}else{
						Gfx.fillbox(tx, ty, button[i].position.width, button[i].position.height, Col.NIGHTBLUE);
					}
					Gfx.setlinethickness(2);
					Gfx.drawbox(tx, ty, button[i].position.width, button[i].position.height, 0xDDDDDD);
					
					//Draw text
					if (button[i].action == "target") {
						Text.display(tx + 10, ty, Main.targetlist[Main.currenttarget].toUpperCase(), Col.GRAY);
					}else if (button[i].action == "build") {
						Text.display(tx + 10, ty, Main.buildlist[Main.currentbuild].toUpperCase(), Col.GRAY);
					}
				}else if (button[i].style == "buildtarget") {
					tx = button[i].position.x;
					ty = button[i].position.y;
					
					Gfx.fillbox(tx, ty, button[i].position.width, button[i].position.height, Col.NIGHTBLUE);
					
					var t:Float = Mouse.y - ty;
					if (Mouse.x > tx && Mouse.x < tx + button[i].position.width && t >= 0) {
						t = Math.floor((t - (t % 20)) / 20);
						if (t >= 0 && t < Main.targetlist.length) {
							Gfx.fillbox(tx, ty + (t * 20), button[i].position.width, 20, 0xFF2B3642);
						}
					}
					
					Gfx.setlinethickness(2);
					Gfx.drawbox(tx, ty, button[i].position.width, button[i].position.height, 0xDDDDDD);
					
					for (i in 0 ... Main.targetlist.length) {
						Text.display(tx + 10, ty + (i * 20), Main.targetlist[i].toUpperCase(), Col.GRAY);
					}
				}else if (button[i].style == "buildbuild") {
					tx = button[i].position.x;
					ty = button[i].position.y;
					
					Gfx.fillbox(tx, ty, button[i].position.width, button[i].position.height, Col.NIGHTBLUE);
					
					var t:Float = Mouse.y - ty;
					if (Mouse.x > tx && Mouse.x < tx + button[i].position.width && t >= 0) {
						t = Math.floor((t - (t % 20)) / 20);
						if (t >= 0 && t < Main.buildlist.length) {
							Gfx.fillbox(tx, ty + (t * 20), button[i].position.width, 20, 0xFF2B3642);
						}
					}
					
					Gfx.setlinethickness(2);
					Gfx.drawbox(tx, ty, button[i].position.width, button[i].position.height, 0xDDDDDD);
					
					for (i in 0 ... Main.buildlist.length) {
						Text.display(tx + 10, ty + (i * 20), Main.buildlist[i].toUpperCase(), Col.GRAY);
					}
				}
			}
		}
	}
	
	public static function deleteall(t:String = ""):Void {
		if (t == "") {
			for (i in 0 ... numbuttons) button[i].active = false;
			numbuttons = 0;
		}else{
			//Deselect any buttons with style t
			for (i in 0 ... numbuttons) {
				if (button[i].active) {
					if (button[i].style == t) {
						button[i].active = false;
					}
				}
			}
		}
	}
	
	public static function selectbutton(t:String):Void {
		//select any buttons with action t
		for (i in 0 ... numbuttons) {
			if (button[i].active) {
				if (button[i].action == t) {
					dobuttonaction(i);
					button[i].selected = true;
				}
			}
		}
	}
	
	public static function deselect(t:String):Void {
		//Deselect any buttons with action t
	  for (i in 0 ... numbuttons) {
			if (button[i].active) {
				if (button[i].action == t) {
					button[i].selected = false;
				}
			}
		}
	}
	
	public static function deselectall(t:String):Void {
		//Deselect any buttons with style t
		for (i in 0 ... numbuttons) {
			if (button[i].active) {
				if (button[i].style == t) {
					button[i].selected = false;
				}
			}
		}
	}
	
	public static function findbuttonbyaction(t:String):Int {
		for (i in 0 ... numbuttons) {
			if (button[i].active) {
				if (button[i].action == t) {
					return i;
				}
			}
		}
		return 0;
	}
	
	public static function dobuttonmoveaction(i:Int):Void {
		currentbutton = button[i].action;
	}	
	
	public static function dobuttonaction(i:Int):Void {
		currentbutton = button[i].action;
		button[i].press();
		
		if (currentbutton == "compile") {
			if (!Main.processrunning) {
				Main.compileclicked = true;
				Console.log("[Compiling to " + Main.targetlist[Main.currenttarget].toUpperCase() + "...]");
				if (Main.currenttarget == 3) {
					Console.log("> openfl test " + Main.targetlist[Main.currenttarget] + " [this may take some time]");
				}else {
					Console.log("> openfl test " + Main.targetlist[Main.currenttarget]);
				}
				Main.runcommand("openfl");
				
				button[i].press();
				button[i].text = "CANCEL";
				deleteall("build");
				deleteall("droplist");
				deleteall("buildtarget");
				deleteall("downarrow");
			}else {
				Main.endthread();
				Main.createdropdownlist();
				button[i].press();
				button[i].text = "COMPILE";
				
			}
		}else	if (currentbutton == "build") {
			if (listopen) {
				listopen = false;
				deleteall("buildtarget");
				deleteall("buildbuild");
			}else {
				listopen = true;
			  addlist(Convert.toint(button[i].position.x), Convert.toint(button[i].position.y + 20), Convert.toint(button[i].position.width), "buildbuild");	
			}
		}else	if (currentbutton == "target") {
			if (listopen) {
				listopen = false;
				deleteall("buildtarget");
				deleteall("buildbuild");
			}else {
				listopen = true;
			  addlist(Convert.toint(button[i].position.x), Convert.toint(button[i].position.y + 20), Convert.toint(button[i].position.width), "buildtarget");	
			}
		}else	if (currentbutton == "buildtarget") {
			tx = button[i].position.x;
			ty = button[i].position.y;
			
			var t:Float = Mouse.y - ty;
			if (Mouse.x > tx && Mouse.x < tx + button[i].position.width && t >= 0) {
				t = Math.floor((t - (t % 20)) / 20);
				if (t >= 0 && t < Main.targetlist.length) {
					Main.currenttarget = Convert.toint(t);
					deleteall("buildtarget");
					listopen = false;
				}
			}
		}else	if (currentbutton == "buildbuild") {
			tx = button[i].position.x;
			ty = button[i].position.y;
			
			var t:Float = Mouse.y - ty;
			if (Mouse.x > tx && Mouse.x < tx + button[i].position.width && t >= 0) {
				t = Math.floor((t - (t % 20)) / 20);
				if (t >= 0 && t < Main.buildlist.length) {
					Main.currentbuild = Convert.toint(t);
					deleteall("buildbuild");
					listopen = false;
				}
			}
		}
	}
	
	public static var button:Array<Guibutton> = new Array<Guibutton>();
	public static var numbuttons:Int;
	public static var maxbuttons:Int;
	
	public static var tx:Float;
	public static var ty:Float;
	public static var timage:Int;
	public static var currentbutton:String;
	
	public static var listopen:Bool;
}
