import XCTest
@testable import ReerCodable
import Testing
import Foundation

@Codable
@Copyable
public struct Model6 {
    var name: String
    let id: Int
    var desc: String?
}

@Codable
@Copyable
class Model7<Element: Codable> {
    var name: String
    let id: Int
    var desc: String?
    var data: Element?
}

@Codable
@Copyable
enum Season {
    case spring, summer(Int), fall, winter(Int)
}

extension TestReerCodable {
    @Test
    func copyStruct() throws {
        let model = Model6(name: "phoenix", id: 123, desc: "Swift Developer")
        let newModel = model.copy()
        #expect(newModel.name == model.name)
        #expect(newModel.id == model.id)
        #expect(newModel.desc == model.desc)
        
        let newModel2 = model.copy(name: "reer")
        #expect(newModel2.name == "reer")
        
        let newModel3 = model.copy(name: "reer3", id: 567, desc: "python developer")
        #expect(newModel3.name == "reer3")
        #expect(newModel3.id == 567)
        #expect(newModel3.desc == "python developer")
    }
    
    @Test
    func copyClass() throws {
        let model = Model7(name: "phoenix", id: 123, desc: "Swift Developer", data: 55)
        let newModel = model.copy()
        #expect(newModel.name == model.name)
        #expect(newModel.id == model.id)
        #expect(newModel.desc == model.desc)
        #expect(newModel.data == model.data)
        #expect(ObjectIdentifier(model) != ObjectIdentifier(newModel))
        
        let newModel2 = model.copy(name: "reer")
        #expect(newModel2.name == "reer")
        #expect(ObjectIdentifier(model) != ObjectIdentifier(newModel2))
        
        let newModel3 = model.copy(name: "reer3", id: 567, desc: "python developer", data: 66)
        #expect(newModel3.name == "reer3")
        #expect(newModel3.id == 567)
        #expect(newModel3.desc == "python developer")
        #expect(newModel3.data == 66)
        #expect(ObjectIdentifier(model) != ObjectIdentifier(newModel3))
    }
    
    @Test
    func copyEnum() throws {
        let season = Season.summer(33)
        if case .summer(let temperature ) = season.copy() {
            #expect(temperature == 33)
        } else {
            Issue.record("copy enum failed")
        }
    }
}
