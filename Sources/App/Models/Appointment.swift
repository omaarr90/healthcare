import Vapor
import Fluent
import Foundation

final class Appointment: Model {
    var id: Node?
    var date: String
    var time: String
    var doctor: Node?
    var status: String // Available, Booked, Confirmed
    var token: String?
    var doctor_id: Node?
    
    init(date: String, time: String, doctor: Node?, status: String = "Available", token: String?) {
        self.id = nil //UUID().uuidString.makeNode()
        self.date = date
        self.time = time
        self.doctor = doctor
        self.status = status
        self.token = token
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        date = try node.extract("date")
        time = try node.extract("time")
        doctor = try node.extract("doctor_id")
        status = try node.extract("status")
        token = try node.extract("token")
    }
    
    func makeNode(context: Context) throws -> Node {
        
        return try Node(node: [
            "id": id,
            "date": date,
            "time": time,
            "status": status,
            "doctor_id": doctor,
            "token": token
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
            appointments.string("status")
            appointments.string("token", length: 1000, optional: true, unique: true, default: nil)
            appointments.parent(Doctor.self, optional: false, unique: false, default: nil)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("appointments")
    }
}
