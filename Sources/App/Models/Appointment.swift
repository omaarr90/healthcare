import Vapor
import Fluent
import Foundation

final class Appointment: Model {
    var id: Node?
    var date: String
    var time: String
    var doctor: Int
    
    init(date: String, time: String, doctor: Int) {
        self.id = UUID().uuidString.makeNode()
        self.date = date
        self.time = time
        self.doctor = doctor
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        date = try node.extract("date")
        time = try node.extract("time")
        doctor = try node.extract("doctor")
    }
    
    func makeNode(context: Context) throws -> Node {
        
        return try Node(node: [
            "id": id,
            "date": date,
            "time": time,
            "doctor": doctor
            ])
    }
}


extension Appointment {
}

extension Appointment: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("appointments") { appointments in
            appointments.id()
            appointments.string("date")
            appointments.string("time")
            appointments.parent(Doctor.self, optional: false, unique: false, default: nil)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("appointments")
    }
}
