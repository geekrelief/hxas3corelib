package com.adobe.serialization.json;

import com.adobe.serialization.json.JSON;
import com.adobe.serialization.json.JSONDecoder;
import com.adobe.serialization.json.JSONEncoder;
import com.adobe.serialization.json.JSONParseError;
import com.adobe.serialization.json.JSONToken;
import com.adobe.serialization.json.JSONTokenType;
import com.adobe.serialization.json.JSONTokenizer;


class JSONTest extends haxe.unit.TestCase{
	public function testEncoder() {
		var a:Dynamic = {a:1, b:"hi"};
		var e:JSONEncoder = new JSONEncoder(a);
		var s:String = e.getString();
		assertTrue(s == '{"b":"hi","a":1}');
	}
	
	public function testDecoder() {
		var s:String = '{"b":"hi","a":1}';
		var d:JSONDecoder = new JSONDecoder(s);
		var b:Dynamic = d.getValue();
		assertEquals(Reflect.field(b, "b"), "hi");
	}
}
