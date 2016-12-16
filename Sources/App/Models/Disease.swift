import Vapor
import Fluent
import Foundation

final class Disease: Model {
    var id: Node?
    var name: String
//    var doctors: Children<Doctor>
//    var symptoms: Children<Symptom>
//    var exists: Bool = false
    
    init(name: String) {
        self.id = UUID().uuidString.makeNode()
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


extension Disease {
    static func mainDisease(symptos: [Int]) throws -> Disease
    {
        var mostFrequent = symptos[0]
        
        var counts = [Int: Int]()
        
        symptos.forEach { counts[$0] = (counts[$0] ?? 0) + 1 }
        
        if let (value, _) = counts.max(by: {$0.1 < $1.1}) {
            mostFrequent = value
        }
        
        return try Disease.find(mostFrequent)!
        
    }
}

extension Disease: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("diseases") { diseases in
            diseases.id()
            diseases.string("name")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("diseases")
    }
}
