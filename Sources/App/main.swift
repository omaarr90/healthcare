import Vapor
import VaporPostgreSQL
import Foundation
import HTTP
import Cookies
import Turnstile
import TurnstileCrypto
import TurnstileWeb
import Auth
import Sessions

import TLS
import Transport


//setupClient()

let drop = Droplet()
try drop.addProvider(VaporPostgreSQL.Provider)
drop.preparations = [Doctor.self, Symptom.self, Disease.self, City.self, Appointment.self, Comment.self, User.self]
drop.view = LeafRenderer(viewsDir: drop.viewsDir)

let memory = MemorySessions()
let sessions = SessionsMiddleware(sessions: memory)
drop.middleware.append(sessions)

let mailClient = MailClient(drop: drop)
let adminC = AdminController(drop: drop)

try mailClient.sendTestEmail()

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
    let doctorO = try doctor?.makeNode()
    let comments = try Comment.query().filter("doctor_id", doctorID).all().makeNode()
    let appointments = try Appointment.query().filter("doctor_id", (doctor!.id!)).all().makeNode()
    var context = ["doctor": doctorO, "appointments": appointments, "comments": comments]
    
    if let name = try request.session().data["emailIsValid"]?.string {
        if name == "true" {
            context["emailError"] = "* البريد الالكتروني المدخل غير صحيح".makeNode()
        }
    }
    
    try request.session().data["emailIsValid"] = ""
    
    return try drop.view.make("doctor", Node(node: context))

}

drop.post("selectAppointment") { request in
    guard let appointmentID = request.data["appointmentSelected"]?.int, let emailAddress = request.data["emailAddress"]?.string   else {
        throw Abort.badRequest
    }
    
    var appointment = try Appointment.query().filter("id", appointmentID).all().first
    let doctor = (appointment?.doctor!)!
    
    if !emailAddress.passes(Email.self){
        try request.session().data["emailIsValid"] = "true"
        let response = Response(redirect: "/doctors/\(doctor.int!)")
        return response
    }
    
    if appointment?.status != "Available" {
        return try drop.view.make("appointmentConfirmation", Node(node: ["title": "الموعد غير متاح", "message": "لقد تم حجز هذا الموعد مسبقا من فضلك قم بحجز موعد اخر"]))
    }
    
    appointment?.status = "Booked"
    appointment?.token = UUID().uuidString
    
    //try MailClient.sendAppointmentConfirmation(to: emailAddress, token: (appointment?.token)!)
    try mailClient.sendAppointmentConfirmation(to: emailAddress, token: (appointment?.token)!)
    
    try appointment?.save()
    
    return try drop.view.make("appointmentConfirmation", Node(node: ["title": "تم حجز هذا الموعد", "message": "لقد قمنا بإرسال بريد الكتروني اليك. من فضلك استخدم الرابط المرفق لتأكيد الموعد"]))
}

drop.get("confirmAppintment") {request in
    guard let token = request.data["token"]?.string else {
        throw Abort.badRequest
    }
    var appointment = try Appointment.query().filter("token", token).all().first
    
    if appointment == nil {
        var response = Response(status: .badRequest)
        return response
    }
    
    appointment?.status = "Confirmed"
    let doctorID = appointment?.doctor
    
    try appointment?.save()
    return try drop.view.make("appintmentFinalStep", Node(node: ["doctor_id": doctorID, "token": token]))
}

drop.post("postComment") { request in
    guard let commentMessage = request.data["comment"]?.string, let doctorID = request.data["doctor_id"]?.int   else {
        throw Abort.badRequest
    }
    
    let doctor = try Doctor.query().filter("id", doctorID).all().first
    let doctor_id = doctor?.id
    
    var comment = Comment(name: commentMessage, doctorID: doctor_id!)
    try comment.save()

    
    var response = Response(redirect: "/doctors/\(doctorID)")
    
    return response
}

drop.post("cancelAppointment") { request in
    guard let token = request.data["token"]?.string else {
        throw Abort.badRequest
    }
    
    var appointment = try Appointment.query().filter("token", token).all().first
    appointment?.token = nil
    appointment?.status = "Available"
    try appointment?.save()
    
    return try drop.view.make("cancelAppointment")
}

drop.post("/search") { req in
    let query = req.data["search_query"]?.string
    
    let doctors = try Doctor.query().filter("name", .contains, query!).all().makeNode()
    
    return try drop.view.make("searchResult", Node(node: ["doctors": doctors]))
}


drop.run()
