import Vapor
import Fluent
import Foundation

final class Disease: Model {
    var id: Node?
    var name: String
    var doctors: [Doctor]
    
    init(name: String, doctors: [Doctor]) {
        self.id = UUID().uuidString.makeNode()
        self.name = name
        self.doctors = doctors
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        doctors = try node.extract("doctors")
    }
    
    func makeNode(context: Context) throws -> Node {
        
        return try Node(node: [
            "id": id,
            "name": name,
            "doctors": Node(node:doctors)
            ])
    }
}

extension Disease {
    /**
     This will automatically fetch from database, using example here to load
     automatically for example. Remove on real models.
     */
    //    public convenience init?(from string: String) throws {
    //        self.init(content: string)
    //    }
}

extension Disease: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("diseases") { users in
            users.id()
            users.string("name")
//            users.entity("doctors")
        }
    }
    
    static func revert(_ database: Database) throws {
        //
    }
}
