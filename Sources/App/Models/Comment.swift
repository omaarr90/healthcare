import Vapor
import Fluent
import Foundation

final class Comment: Model {
    var id: Node?
    var name: String
    var doctorID: Node?
    
    init(name: String, doctorID: Node? = nil) {
        self.id = nil //UUID().uuidString.makeNode()
        self.name = name
        self.doctorID = doctorID
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        doctorID = try node.extract("doctor_id")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "doctor_id": doctorID
            ])
    }
}


extension Comment {
}

extension Comment: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("comments") { comments in
            comments.id()
            comments.string("name")
            comments.parent(Doctor.self, optional: false, unique: false, default: nil)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("comments")
    }
}
