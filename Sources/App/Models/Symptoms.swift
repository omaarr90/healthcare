import Vapor
import Fluent
import Foundation

final class Symptom: Model {
    var id: Node?
    var name: String
    var disease: Int
    
    init(name: String, disease: Int) {
        self.id = UUID().uuidString.makeNode()
        self.name = name
        self.disease = disease
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        disease = try node.extract("disease_id")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "disease_id": disease
            ])
    }
    
}

extension Symptom {
    /**
     This will automatically fetch from database, using example here to load
     automatically for example. Remove on real models.
     */
//    public convenience init?(from string: String) throws {
//        self.init(content: string)
//    }
}

extension Symptom: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("symptoms") { symptoms in
            symptoms.id()
            symptoms.string("name")
            symptoms.parent(Disease.self, optional: false, unique: false, default: nil)
        }
    }
    
    
    static func revert(_ database: Database) throws {
        try database.delete("symptoms")
    }
}
