import XCTest
@testable import AppleRL

final class AppleRLTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(AppleRL().text, "Hello, World!")
    }
    
    func inferenceTest() throws {
        var actionsArray: [Action] = [Action1(), Action2(), Action3()]
        var e: Env = Env(observableData: ["brightness", "battery", "ambientLight"], actions: actionsArray, actionSize: 3, stateSize: 3)
        let params: Dictionary<String, Any> = ["epsilon": Double(0.1), "learning_rate": Double(0.1), "gamma": Double(0.8)]
        let qnet: DeepQNetwork = DeepQNetwork(env: e, parameters: params)


        do {
            let r1 = qnet.act(state: try MLMultiArray([0.1, 0.1, 0.1]))
            let r2 = qnet.act(state: try MLMultiArray([10, 10, 11]))
            let r3 = qnet.act(state: try MLMultiArray([0.5, 0.1, 0.3]))
            let r4 = qnet.act(state: try MLMultiArray([0.1, 0.1, 0.3]))
            let r5 = qnet.act(state: try MLMultiArray([0.8, 0.1, 0.3]))
            
            XCTAssertNotEqual(r1, r2)
            XCTAssertNotEqual(r2, r3)
            XCTAssertNotEqual(r3, r4)
            XCTAssertNotEqual(r4, r5)
        } catch {
            throw error
        }
    }
    
    func updateTest() throws {
        let r1 = qnet.act(state: try MLMultiArray([0.5, 0.1, 0.1]))
        qnet.update()
        let r2 = qnet.act(state: try MLMultiArray([0.5, 0.1, 0.1]))
        
        XCTAssertNotEqual(r1, r2)
    }
}
