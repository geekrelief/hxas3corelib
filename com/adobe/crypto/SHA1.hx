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

package com.adobe.crypto;

	import com.adobe.utils.IntUtil;
	import flash.utils.ByteArray;
	import utils.Base64;

	/**
	 *  US Secure Hash Algorithm 1 (SHA1)
	 *
	 *  Implementation based on algorithm description at 
	 *  http://www.faqs.org/rfcs/rfc3174.html
	 */
	class SHA1
	{
		/**
		 *  Performs the SHA1 hash algorithm on a string.
		 *
		 *  @param s		The string to hash
		 *  @return			A string containing the hash value of s
		 *  @langversion	ActionScript 3.0
		 *  @playerversion	9.0
		 *  @tiptext
		 */
		public static function hash( s:String ):String
		{
			var blocks:Array<Int> = createBlocksFromString( s );
			var byteArray:ByteArray = hashBlocks( blocks );
			
			return IntUtil.toHex( byteArray.readInt(), true )
					+ IntUtil.toHex( byteArray.readInt(), true )
					+ IntUtil.toHex( byteArray.readInt(), true )
					+ IntUtil.toHex( byteArray.readInt(), true )
					+ IntUtil.toHex( byteArray.readInt(), true );
		}
		
		/**
		 *  Performs the SHA1 hash algorithm on a ByteArray.
		 *
		 *  @param data		The ByteArray data to hash
		 *  @return			A string containing the hash value of data
		 *  @langversion	ActionScript 3.0
		 *  @playerversion	9.0
		 */
		public static function hashBytes( data:ByteArray ):String
		{
			var blocks:Array<Int> = SHA1.createBlocksFromByteArray( data );
			var byteArray:ByteArray = hashBlocks(blocks);
			
			return IntUtil.toHex( byteArray.readInt(), true )
					+ IntUtil.toHex( byteArray.readInt(), true )
					+ IntUtil.toHex( byteArray.readInt(), true )
					+ IntUtil.toHex( byteArray.readInt(), true )
					+ IntUtil.toHex( byteArray.readInt(), true );
		}
		
		/**
		 *  Performs the SHA1 hash algorithm on a string, then does
		 *  Base64 encoding on the result.
		 *
		 *  @param s		The string to hash
		 *  @return			The base64 encoded hash value of s
		 *  @langversion	ActionScript 3.0
		 *  @playerversion	9.0
		 *  @tiptext
		 */
		public static function hashToBase64( s:String ):String
		{
			var blocks:Array<Int> = createBlocksFromString( s );
			var byteArray:ByteArray = hashBlocks( blocks );

			 var charsInByteArray:String = ""; 
            byteArray.position = 0;

            for (j in 0...byteArray.length)
            {
                var byte:UInt = byteArray.readUnsignedByte();
                charsInByteArray += String.fromCharCode(byte);
            }
			return Base64.encode(charsInByteArray);
		}
		
		private static function hashBlocks( blocks:Array<Int> ):ByteArray
		{
			// initialize the h's
			var h0:Int = 0x67452301;
			var h1:Int = 0xefcdab89;
			var h2:Int = 0x98badcfe;
			var h3:Int = 0x10325476;
			var h4:Int = 0xc3d2e1f0;
			
			var len:Int = blocks.length;
			var w:Array<Int> = new Array();
			
			// loop over all of the blocks
			var i:Int = 0;
			while ( i < len) {
			
				// 6.1.c
				var a:Int = h0;
				var b:Int = h1;
				var c:Int = h2;
				var d:Int = h3;
				var e:Int = h4;
				
				// 80 steps to process each block
				// TODO: unroll for faster execution, or 4 loops of
				// 20 each to avoid the k and f function calls
				for ( t in  0...80) {
					
					if ( t < 16 ) {
						// 6.1.a
						w[ t ] = blocks[ i + t ];
					} else {
						// 6.1.b
						w[ t ] = IntUtil.rol( w[ t - 3 ] ^ w[ t - 8 ] ^ w[ t - 14 ] ^ w[ t - 16 ], 1 );
					}
					
					// 6.1.d
					var temp:Int = IntUtil.rol( a, 5 ) + f( t, b, c, d ) + e + w[ t ] + k( t );
					
					e = d;
					d = c;
					c = IntUtil.rol( b, 30 );
					b = a;
					a = temp;
				}
				
				// 6.1.e
				h0 += a;
				h1 += b;
				h2 += c;
				h3 += d;
				h4 += e;		
				i += 16 ;
			}
			
			var byteArray:ByteArray = new ByteArray();
			byteArray.writeInt(h0);
			byteArray.writeInt(h1);
			byteArray.writeInt(h2);
			byteArray.writeInt(h3);
			byteArray.writeInt(h4);
			byteArray.position = 0;
			return byteArray;
		}

		/**
		 *  Performs the logical function based on t
		 */
		private static function f( t:Int, b:Int, c:Int, d:Int ):Int {
			if ( t < 20 ) {
				return ( b & c ) | ( ~b & d );
			} else if ( t < 40 ) {
				return b ^ c ^ d;
			} else if ( t < 60 ) {
				return ( b & c ) | ( b & d ) | ( c & d );
			}
			return b ^ c ^ d;
		}
		
		/**
		 *  Determines the constant value based on t
		 */
		private static function k( t:Int ):Int {
			if ( t < 20 ) {
				return 0x5a827999;
			} else if ( t < 40 ) {
				return 0x6ed9eba1;
			} else if ( t < 60 ) {
				return 0x8f1bbcdc;
			}
			return 0xca62c1d6;
		}
					
		/**
		 *  Converts a ByteArray to a sequence of 16-word blocks
		 *  that we'll do the processing on.  Appends padding
		 *  and length in the process.
		 *
		 *  @param data		The data to split into blocks
		 *  @return			An array containing the blocks into which data was split
		 */
		private static function createBlocksFromByteArray( data:ByteArray ):Array<Int>
		{
			var oldPosition:Int = data.position;
			data.position = 0;
			
			var blocks:Array<Int> = new Array();
			var len:Int = data.length * 8;
			var mask:Int = 0xFF; // ignore hi byte of characters > 0xFF
			var i:Int = 0;
			while ( i < len)
			{
				blocks[ i >> 5 ] |= ( data.readByte() & mask ) << ( 24 - i % 32 );
				i += 8 ;
			}
			
			// append padding and length
			blocks[ len >> 5 ] |= 0x80 << ( 24 - len % 32 );
			blocks[ ( ( ( len + 64 ) >> 9 ) << 4 ) + 15 ] = len;
			
			data.position = oldPosition;
			
			return blocks;
		}
					
		/**
		 *  Converts a string to a sequence of 16-word blocks
		 *  that we'll do the processing on.  Appends padding
		 *  and length in the process.
		 *
		 *  @param s	The string to split into blocks
		 *  @return		An array containing the blocks that s was split into.
		 */
		private static function createBlocksFromString( s:String ):Array<Int>
		{
			var blocks:Array<Int> = new Array();
			var len:Int = s.length * 8;
			var mask:Int = 0xFF; // ignore hi byte of characters > 0xFF
			var i:Int = 0;
			while ( i < len) {
				//blocks[ i >> 5 ] |= ( s.charCodeAt( i / 8 ) & mask ) << ( 24 - i % 32 );
				blocks[ i >> 5 ] |= ( s.charCodeAt( i >> 3 ) & mask ) <<  ( 24 - i % 32 );
				i += 8 ;
			}
			
			// append padding and length
			blocks[ len >> 5 ] |= 0x80 << ( 24 - len % 32 );
			blocks[ ( ( ( len + 64 ) >> 9 ) << 4 ) + 15 ] = len;
			return blocks;
		}
		
	}