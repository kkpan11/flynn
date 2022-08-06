import Flynn
import WebKit

struct TestStruct {
    let message: String
}

class TestActor: Actor {
    
    internal func _beTest() {
        print("Hello World!")
    }
    
    internal func _beTestStruct(value: WKWebView) {
        
    }
    
    private func bar() {
        self._beTest()
    }
}

let actor = TestActor()

print("BEFORE")
actor.beTest()
print("AFTER")

Flynn.shutdown()
