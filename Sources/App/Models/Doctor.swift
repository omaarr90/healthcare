import Vapor
import Fluent
import Foundation

final class Doctor: Model {
    var id: Node?
    var name: String
//    var hospital: Hospital
    var email: String
    var phoneNumber: String
    
    init(name: String, hospital: Hospital, email: String, phoneNumber: String) {
        self.id = UUID().uuidString.makeNode()
        self.name = name
//        self.hospital = hospital
        self.email = email
        self.phoneNumber = phoneNumber
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
//        hospital = try node.extract("hospital")
        email = try node.extract("email")
        phoneNumber = try node.extract("phoneNumber")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
//            "hospital": hospital.makeNode(),
            "email": email,
            "phoneNumber": phoneNumber
            ])
    }
}

extension Doctor {
    /**
     This will automatically fetch from database, using example here to load
     automatically for example. Remove on real models.
     */
//    public convenience init?(from string: String) throws {
//        self.init(content: string)
//    }
}

extension Doctor: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("doctors") { doctors in
            doctors.id()
            doctors.string("name")
            doctors.string("email")
            doctors.string("phoneNumber")
            doctors.parent(Disease.self, optional: false, unique: false, default: nil)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("doctors")
    }
}
