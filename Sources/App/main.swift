import Vapor
import VaporPostgreSQL

let drop = Droplet()
try drop.addProvider(VaporPostgreSQL.Provider)
drop.preparations = [Doctor.self, Symptom.self, Disease.self, City.self, Appointment.self, Comment.self]
drop.view = LeafRenderer(viewsDir: drop.viewsDir)

drop.get() { req in
    return try drop.view.make("welcome")
}

drop.get("diagnosis") { request in
//    let sympts = try ["Sympt1", "Sympt2", "Sympt3"].makeNode()
    let sympts = try Symptom.all().makeNode()
    return try drop.view.make("diagnosis", Node(node: ["sympts": sympts]))
}

drop.post("diagnosis") { request in
    guard let sympts = request.data["checkbox"]?.array  else {
        let sympts = try Symptom.all().makeNode()
        return try drop.view.make("diagnosis", Node(node: ["error": "please select symptoms", "sympts": sympts]))
    }
    var options = [Int]()
    for option in sympts {
        options.append(option.int!)
    }
    
    let mainDisease = try Disease.mainDisease(symptos: options)
    
    return try drop.view.make("diagnosisResult", Node(node: ["mainDisease": mainDisease]))
}

drop.get("appointments") { request in
    let cities = try City.all().makeNode()
    let diseases = try Disease.all().makeNode()
    return try drop.view.make("appointments", Node(node: ["cities": cities,
                                                          "diseases": diseases]))
}

drop.post("doctorappointments") { request in
    guard let city = request.data["citySelected"]?.string, let disease = request.data["diseaseSelected"]?.string   else {
        throw Abort.badRequest
    }
    
    let doctors = try Doctor.doctors(for: disease, in: city).makeNode()
    return try drop.view.make("doctorAppointments", Node(node: ["doctors": doctors]))
}

drop.get("doctors", Int.self) { request, doctorID in
    let doctor = try Doctor.query().filter("id", doctorID).first()
    return try drop.view.make("doctor", Node(node: ["doctor": doctor]))

}

drop.run()
