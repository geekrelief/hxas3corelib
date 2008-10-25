import com.adobe.crypto.MD5Test;
import com.adobe.serialization.json.JSONTest;

class Main
{
    static function main() {
		var runner = new haxe.unit.TestRunner();
		runner.add(new MD5Test());
		runner.add(new JSONTest());
		runner.run();
	}
}
