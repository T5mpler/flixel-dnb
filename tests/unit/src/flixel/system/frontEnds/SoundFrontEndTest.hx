package flixel.system.frontEnds;

import flixel.FlxG;

class SoundFrontEndTest
{
	#if FLX_SOUND_SYSTEM
	@Test // #1511
	function testPlayInvalidSoundPathNoCrash()
	{
		FlxG.sound.play("assets/invalid");
	}

	@Test // #1511
	function testPlayMusicInvalidSoundPathNoCrash()
	{
		FlxG.sound.playMusic("assets/invalid");
	}

	@Test // #1511
	function testLoadInvalidSoundPathNoCrash()
	{
		FlxG.sound.create("assets/invalid").play();
	}
	#end
	
	function debugSound(ms:Float)//:Sound
	{
		return new DebugSound(ms);
	}
}

@:forward
abstract DebugSound(Sound) to Sound
{
	public static inline var ID3_ARTIST = "HaxeFlixel";
	public static inline var ID3_ALBUM = "Unit Tests";
	public static inline var ID3_COMMENT = "Used to test FlxSounds";
	public static inline var ID3_GENRE = "Techno";
	public static inline var ID3_YEAR = "2026";
	
	inline static var SAMPLE_RATE = 44100;
	inline static var HEADER_BYTES
		= '524946460000000057415645666d7420100000000100010044ac000044ac0000020008006461746100000000';
		// |       |       |       |       |       |   |   |       |       |   |   |       |       
		// R_I_F_F_<-size->W_A_V_E_f_m_t_ _<--16--><01><ch><44100-><bytrte><ba><br>d_a_t_a_<sampls>
		
	
	public function new (ms:Float)
	{
		this = new Sound();
		
		final numSamples = Std.int(SAMPLE_RATE * (ms / 1000));
		final samples = haxe.io.Bytes.alloc(numSamples);
		for (i in 0...numSamples)
			samples.set(i, 0x80);
		
		final rawBytes = haxe.io.Bytes.ofHex(HEADER_BYTES + samples.toHex());
		rawBytes.setInt32(4, 36 + samples.length);
		rawBytes.setInt32(40, samples.length);
		
		final bytes = openfl.utils.ByteArray.fromBytes(rawBytes);
		this.loadCompressedDataFromByteArray(bytes, bytes.length);
	}
}