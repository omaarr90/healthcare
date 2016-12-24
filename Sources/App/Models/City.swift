import Vapor
import Fluent
import Foundation

final class City: Model {
    var id: Node?
    var name: String
    
    init(name: String) {
        self.id = nil //UUID().uuidString.makeNode()
        self.name = name
        //        self.doctors = self.children(Doctor.self).all()
        //        self.symptoms = symptoms
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        //        doctors = try node.extract("doctors")
        //        symptoms = try node.extract("symptoms")
    }
    
    func makeNode(context: Context) throws -> Node {
        
        return try Node(node: [
            "id": id,
            "name": name,
            //            "doctors": self.c,
            //            "symptoms": Node(node:symptoms)
            ])
    }
}


extension City {
}

extension City: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("citys") { cities in
            cities.id()
            cities.string("name")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("citys")
    }
}
