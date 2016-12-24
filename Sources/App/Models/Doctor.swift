import Vapor
import Fluent
import Foundation

final class Doctor: Model {
    var id: Node?
    var name: String
    var hospital: String
    var email: String
    var phoneNumber: String
    var spciality: String
    var city: Node?
    var disease: Node?
    
    var comments: [Comment] {
        get {
            do {
                return try Comment.query().filter("doctor_id", self.id!).all()
            } catch {
                return []
            }
        }
    }
    
    init(name: String, hospital: String, email: String, phoneNumber: String, city: Node?, spciality: String, disease: Node?) {
        self.id = nil //UUID().uuidString.makeNode()
        self.name = name
        self.hospital = hospital
        self.email = email
        self.phoneNumber = phoneNumber
        self.spciality = spciality
        self.city = city
        self.disease = disease
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        hospital = try node.extract("hospital")
        email = try node.extract("email")
        phoneNumber = try node.extract("phonenumber")
        spciality = try node.extract("spciality")
        city = try node.extract("city_id")
        disease = try node.extract("disease_id")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "hospital": hospital,
            "email": email,
            "phonenumber": phoneNumber,
            "spciality": spciality,
            "comments": comments.makeNode(),
            "city_id": city,
            "disease_id": disease
            ])
    }
}

extension Doctor {
    static func doctors(for disease: String, in city: String) throws -> [Doctor]  {
        return try Doctor.query().filter("disease_id", disease).filter("city_id", city).all()
    }
    
}

extension Doctor: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("doctors") { doctors in
            doctors.id()
            doctors.string("name")
            doctors.string("email")
            doctors.string("phonenumber")
            doctors.string("hospital")
            doctors.string("spciality")
            doctors.parent(Disease.self, optional: false, unique: false, default: nil)
            doctors.parent(City.self, optional: false, unique: false, default: nil)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("doctors")
    }
}
