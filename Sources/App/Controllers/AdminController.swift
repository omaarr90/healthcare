//
//  AdminController.swift
//  PatientHospitalSystem
//
//  Created by Hayes Alshammari on 3/24/1438 AH.
//
//

import Vapor
import HTTP
class AdminController
{
    init(drop: Droplet) {
        drop.get("/admin/", handler: home)
        //Cities
        drop.get("/admin/cities", handler: cities)
        drop.get("/admin/cities/:cityID", handler: cityDetails)
        drop.post("/admin/cities/addCity", handler: addCity)
        drop.post("/admin/cities/deleteCity", handler: deleteCity)
        drop.post("/admin/cities/editCity", handler: editCity)
        
        //Diseases
        drop.get("/admin/diseases", handler: diseases)
        drop.get("/admin/diseases/:diseaseID", handler: diseaseDetails)
        drop.post("/admin/diseases/addDisease", handler: addDisease)
        drop.post("/admin/diseases/deleteDisease", handler: deleteDisease)
        drop.post("/admin/diseases/editDisease", handler: editDisease)

        
        //Symptoms
        drop.get("/admin/symptoms", handler: symptoms)
        drop.get("/admin/symptoms/:symptomID", handler: symptomDetails)
        drop.post("/admin/symptoms/addSymptom", handler: addSymptom)
        drop.post("/admin/symptoms/deleteSymptom", handler: deleteSymptom)
        drop.post("/admin/symptoms/editSymptom", handler: editSymptom)

    }
    
    
    
    func home(request: Request) throws -> ResponseRepresentable
    {
        return try drop.view.make("/admin/adminHome")
    }
    
    
    // Cities
    func cities(request: Request) throws -> ResponseRepresentable
    {
        let cities = try City.query().all().makeNode()
        return try drop.view.make("/admin/adminCties", Node(node: ["cities": cities]))
    }
    
    func cityDetails(request: Request) throws -> ResponseRepresentable
    {
        let cityID = request.parameters["cityID"]?.int ?? 0
        let city = try City.query().filter("id", cityID).all().first?.makeNode()
        
        return try drop.view.make("/admin/adminCityDetail", Node(node: ["city": city]))

    }
    
    func addCity(request: Request) throws -> ResponseRepresentable
    {
        let cityName = request.data["city_name"]?.string
        var city = City(name: cityName!)
        try city.save()
        
        let response = Response(redirect: "/admin/cities")
        return response
    }
    
    func deleteCity(request: Request) throws -> ResponseRepresentable
    {
        let cityID = request.data["city_id"]?.int
        let city = try City.query().filter("id", cityID!)
        try city.delete()
        
        let response = Response(redirect: "/admin/cities")
        return response
    }

    func editCity(request: Request) throws -> ResponseRepresentable
    {
        let cityID = request.data["city_id"]?.int
        let cityName = request.data["city_name"]?.string
        var city = try City.query().filter("id", cityID!).all().first!
        city.name = cityName!
        
        try city.save()
        
        let response = Response(redirect: "/admin/cities")
        return response
    }
    
    
    // Diseases
    func diseases(request: Request) throws -> ResponseRepresentable
    {
        let diseases = try Disease.query().all().makeNode()
        return try drop.view.make("/admin/adminDiseases", Node(node: ["diseases": diseases]))
    }
    
    func diseaseDetails(request: Request) throws -> ResponseRepresentable
    {
        let diseaseID = request.parameters["diseaseID"]?.int ?? 0
        let disease = try Disease.query().filter("id", diseaseID).all().first?.makeNode()
        
        return try drop.view.make("/admin/adminDiseaseDetails", Node(node: ["disease": disease]))
        
    }
    
    func addDisease(request: Request) throws -> ResponseRepresentable
    {
        let diseaseName = request.data["disease_name"]?.string
        var city = Disease(name: diseaseName!)
        try city.save()
        
        let response = Response(redirect: "/admin/diseases")
        return response
    }
    
    func deleteDisease(request: Request) throws -> ResponseRepresentable
    {
        let diseaseID = request.data["disease_id"]?.int
        let disease = try Disease.query().filter("id", diseaseID!)
        try disease.delete()
        
        let response = Response(redirect: "/admin/diseases")
        return response
    }
    
    func editDisease(request: Request) throws -> ResponseRepresentable
    {
        let diseaseID = request.data["disease_id"]?.int
        let diseaseName = request.data["disease_name"]?.string
        var disease = try Disease.query().filter("id", diseaseID!).all().first!
        disease.name = diseaseName!
        
        try disease.save()
        
        let response = Response(redirect: "/admin/diseases")
        return response
    }

    
    //Symptoms
    func symptoms(request: Request) throws -> ResponseRepresentable
    {
        let diseases = try Disease.query().all().makeNode()
        let symptoms = try Symptom.query().all().makeNode()
        return try drop.view.make("/admin/adminSymptoms", Node(node: ["diseases": diseases, "symptoms": symptoms]))
    }
    
    func symptomDetails(request: Request) throws -> ResponseRepresentable
    {
        let symptomID = request.parameters["symptomID"]?.int ?? 0
        let symptom = try Symptom.query().filter("id", symptomID).all().first?.makeNode()
        let diseases = try Disease.query().all().makeNode()
        
        return try drop.view.make("/admin/adminSymptomDetail", Node(node: ["diseases": diseases, "symptom": symptom]))
        
    }
    
    func addSymptom(request: Request) throws -> ResponseRepresentable
    {
        let symptomName = request.data["symptom_name"]?.string
        let diseaseID = request.data["diseaseSelected"]?.int
        let disease = try Disease.query().filter("id", diseaseID!).first()
        
        var symptom = Symptom(name: symptomName!, disease: disease?.id)
        try symptom.save()
        
        let response = Response(redirect: "/admin/symptoms")
        return response
    }
    
    func deleteSymptom(request: Request) throws -> ResponseRepresentable
    {
        let diseaseID = request.data["symptom_id"]?.int
        let disease = try Symptom.query().filter("id", diseaseID!)
        try disease.delete()
        
        let response = Response(redirect: "/admin/symptoms")
        return response
    }
    
    func editSymptom(request: Request) throws -> ResponseRepresentable
    {
        let symptomID = request.data["symptom_id"]?.int
        let symptomName = request.data["symptom_name"]?.string
        let diseaseID = request.data["diseaseSelected"]?.int
        
        var symptom = try Symptom.query().filter("id", symptomID!).all().first!
        let disease = try Disease.query().filter("id", diseaseID!).all().first!
        
        symptom.name = symptomName!
        symptom.disease = disease.id
        
        try symptom.save()
        
        let response = Response(redirect: "/admin/symptoms")
        return response
    }

    
    //Doctors
    func doctors(request: Request) throws -> ResponseRepresentable
    {
        let doctors = try Doctor.query().all().makeNode()
        let diseases = try Disease.query().all().makeNode()
        let cities = try City.query().all().makeNode()
        return try drop.view.make("/admin/adminDoctors", Node(node: ["diseases": diseases, "doctors": doctors, "cities": cities]))
    }
    
    func doctorDetails(request: Request) throws -> ResponseRepresentable
    {
        let doctorID = request.parameters["doctorID"]?.int ?? 0
        let doctor = try Doctor.query().filter("id", doctorID).all().first?.makeNode()
        let diseases = try Disease.query().all().makeNode()
        let cities = try City.query().all().makeNode()
        
        return try drop.view.make("/admin/addminDoctorDetail", Node(node: ["diseases": diseases, "doctor": doctor, "cities": cities]))
        
    }
    
    func addDoctor(request: Request) throws -> ResponseRepresentable
    {
        let doctorName = request.data["doctor_name"]?.string
        let doctorEmail = request.data["docctor_email"]?.string
        let doctorPhoneNumber = request.data["doctor_phonenumber"]?.string
        let doctorHospital = request.data["doctor_hospital"]?.string
        let doctorSpciality = request.data["doctor_spciality"]?.string
        
        let diseaseID = request.data["diseaseSelected"]?.int
        let disease = try Disease.query().filter("id", diseaseID!).first()

        let cityID = request.data["citySelected"]?.int
        let city = try City.query().filter("id", cityID!).first()

        var doctor = Doctor(name: doctorName!, hospital: doctorHospital!, email: doctorEmail!, phoneNumber: doctorPhoneNumber!, city: city?.id, spciality: doctorSpciality!, disease: disease?.id)
        
        try doctor.save()
        
        let response = Response(redirect: "/admin/doctors")
        return response
    }
    
    func deleteDoctor(request: Request) throws -> ResponseRepresentable
    {
        let doctorID = request.data["doctor_id"]?.int
        let doctor = try Doctor.query().filter("id", doctorID!)
        try doctor.delete()
        
        let response = Response(redirect: "/admin/doctors")
        return response
    }
    
    func editDoctor(request: Request) throws -> ResponseRepresentable
    {
        let doctorID = request.data["doctor_id"]?.int
        
        let doctorName = request.data["doctor_name"]?.string
        let doctorEmail = request.data["docctor_email"]?.string
        let doctorPhoneNumber = request.data["doctor_phonenumber"]?.string
        let doctorHospital = request.data["doctor_hospital"]?.string
        let doctorSpciality = request.data["doctor_spciality"]?.string
        
        let diseaseID = request.data["diseaseSelected"]?.int
        let disease = try Disease.query().filter("id", diseaseID!).first()
        
        let cityID = request.data["citySelected"]?.int
        let city = try City.query().filter("id", cityID!).first()
        
        var doctor = try Doctor.query().filter("id", doctorID!).all().first!
        
        doctor.name = doctorName!
        doctor.email = doctorEmail!
        doctor.phoneNumber = doctorPhoneNumber!
        doctor.hospital = doctorHospital!
        doctor.spciality = doctorSpciality!
        
        doctor.city = city?.id
        doctor.disease = disease?.id
        
        try doctor.save()
        
        let response = Response(redirect: "/admin/doctor")
        return response
    }

}
