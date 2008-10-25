/*
  Copyright (c) 2008, Adobe Systems Incorporated
  All rights reserved.

  Redistribution and use in source and binary forms, with or without 
  modification, are permitted provided that the following conditions are
  met:

  * Redistributions of source code must retain the above copyright notice, 
    this list of conditions and the following disclaimer.
  
  * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the 
    documentation and/or other materials provided with the distribution.
  
  * Neither the name of Adobe Systems Incorporated nor the names of its 
    contributors may be used to endorse or promote products derived from 
    this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
  IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR 
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package com.adobe.serialization.json; 


	class JSONEncoder {
	
		/** The string that is going to represent the object we're encoding */
		private var jsonString:String;
		
		/**
		 * Creates a new JSONEncoder.
		 *
		 * @param o The object to encode as a JSON string
		 * @langversion ActionScript 3.0
		 * @playerversion Flash 9.0
		 * @tiptext
		 */
		public function new( value:Dynamic ) {
			jsonString = convertToString( value );
		
		}
		
		/**
		 * Gets the JSON string from the encoder.
		 *
		 * @return The JSON string representation of the object
		 * 		that was passed to the constructor
		 * @langversion ActionScript 3.0
		 * @playerversion Flash 9.0
		 * @tiptext
		 */
		public function getString():String {
			return jsonString;
		}
		
		/**
		 * Converts a value to it's JSON string equivalent.
		 *
		 * @param value The value to convert.  Could be any 
		 *		type (object, number, array, etc)
		 */
		private function convertToString( value:Dynamic ):String {
			
			// determine what value is and convert it based on it's type
			if ( Std.is( value, String) ) {
				
				// escape the string so it's formatted correctly
				return escapeString( cast( value, String) );
				
			} else if ( Std.is( value, Float) ) {
				
				// only encode numbers that finate
				return Math.isFinite( cast( value, Float)) ? value.toString() : "null";

			} else if ( Std.is( value, Bool) ) {
				
				// convert boolean to string easily
				return value ? "true" : "false";

			} else if ( Std.is( value, Array) ) {
			
				// call the helper method to convert an array
				return arrayToString( cast( value, Array<Dynamic>) );
			
			} else if ( Reflect.isObject( value ) ) {
			
				// call the helper method to convert an object
				return objectToString( value );
			}
            return "null";
		}
		
		/**
		 * Escapes a string accoding to the JSON specification.
		 *
		 * @param str The string to be escaped
		 * @return The string with escaped special characters
		 * 		according to the JSON specification
		 */
		private function escapeString( str:String ):String {
			// create a string to store the string's jsonstring value
			var s:String = "";
			// current character in the string we're processing
			var ch:String;
			// store the length in a local variable to reduce lookups
			var len:Int = str.length;
			
			// loop over all of the characters in the string
			for ( i in 0...len) {
			
				// examine the character to determine if we have to escape it
				ch = str.charAt( i );
				switch ( ch ) {
				
					case '"':	// quotation mark
						s += "\\\"";
						break;
						
					//case '/':	// solidus
					//	s += "\\/";
					//	break;
						
					case '\\':	// reverse solidus
						s += "\\\\";
						break;
						
/*
					case '\b':	// bell
						s += "\\b";
						break;
						
					case '\f':	// form feed
						s += "\\f";
						break;
*/						
					case '\n':	// newline
						s += "\\n";
						break;
						
					case '\r':	// carriage return
						s += "\\r";
						break;
						
					case '\t':	// horizontal tab
						s += "\\t";
						break;
						
					default:	// everything else
						
						// check for a control character and escape as unicode
						if ( ch < ' ' ) {
							s += "\\u"+StringTools.hex(ch.charCodeAt(0), 4);
						} else {
							// no need to do any special encoding, just pass-through
							s += ch;
							
						}
				}	// end switch
				
			}	// end for loop
						
			return "\"" + s + "\"";
		}
		
		/**
		 * Converts an array to it's JSON string equivalent
		 *
		 * @param a The array to convert
		 * @return The JSON string representation of <code>a</code>
		 */
		private function arrayToString( a:Array<Dynamic> ):String {
			// create a string to store the array's jsonstring value
			var s:String = "";
			
			// loop over the elements in the array and add their converted
			// values to the string
			for ( i in a ) {
				// when the length is 0 we're adding the first element so
				// no comma is necessary
				if ( s.length > 0 ) {
					// we've already added an element, so add the comma separator
					s += ",";
				}
				
				// convert the value to a string
				s += convertToString( i );	
			}
			
			// KNOWN ISSUE:  In ActionScript, Arrays can also be associative
			// objects and you can put anything in them, ie:
			//		myArray["foo"] = "bar";
			//
			// These properties aren't picked up in the for loop above because
			// the properties don't correspond to indexes.  However, we're
			// sort of out luck because the JSON specification doesn't allow
			// these types of array properties.
			//
			// So, if the array was also used as an associative object, there
			// may be some values in the array that don't get properly encoded.
			//
			// A possible solution is to instead encode the Array as an Object
			// but then it won't get decoded correctly (and won't be an
			// Array instance)
						
			// close the array and return it's string value
			return "[" + s + "]";
		}
		
		/**
		 * Converts an object to it's JSON string equivalent
		 *
		 * @param o The object to convert
		 * @return The JSON string representation of <code>o</code>
		 */
		private function objectToString( o:Dynamic ):String
		{
			// create a string to store the object's jsonstring value
			var s:String = "";
			
			// determine if o is a class instance or a plain object
			var classInfo:Dynamic = Type.getClass(o);
			if ( classInfo == null )
			{
				// the value of o[key] in the loop below - store this 
				// as a variable so we don't have to keep looking up o[key]
				// when testing for valid values to convert
				var value:Dynamic;
				
				// loop over the keys in the object and add their converted
				// values to the string
				for ( key in Reflect.fields(o) )
				{
					// assign value to a variable for quick lookup
					value = Reflect.field(o, key);
					
					// don't add function's to the JSON string
					if ( Reflect.isFunction( value ) )
					{
						// skip this key and try another
						continue;
					}
					
					// when the length is 0 we're adding the first item so
					// no comma is necessary
					if ( s.length > 0 ) {
						// we've already added an item, so add the comma separator
						s += ",";
					}
					
					s += escapeString( key ) + ":" + convertToString( value );
				}
			}
			else // o is a class instance
			{
				var c:Class<Dynamic> = Type.getClass(o);
				for ( v in Type.getInstanceFields(c) )
				{
					// skip if function or if retrieved type is null to exclude private vars
					if(Reflect.isFunction(Reflect.field(o, v)) || Reflect.field(o, v) == null){
						continue;
					}

					if ( s.length > 0 ) {
						// We've already added an item, so add the comma separator
						s += ",";
					}
					
					s += escapeString( v ) + ":" 
							+ convertToString( Reflect.field(o, v) );
				}
				
			}
			
			return "{" + s + "}";
		}
		
	}
	
