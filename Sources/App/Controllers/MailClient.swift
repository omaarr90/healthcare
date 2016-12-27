//
//  MailClient.swift
//  PatientHospitalSystem
//
//  Created by Hayes Alshammari on 3/24/1438 AH.
//
//

import Vapor
import SMTP
import TLS
import Transport

func setupClient() {
    defaultClientConfig = {
        return try TLS.Config(context: try Context(mode: .client), certificates: .none, verifyHost: false, verifyCertificates: false, cipher: .compat)
    }
}


class MailClient
{
    var drop: Droplet

    init(drop: Droplet) {
        self.drop = drop
    }
    
    func sendTestEmail() throws
    {
        
    }
    
    
    func sendAppointmentConfirmation(to email: String, token: String) throws
    {
        
        let confirmURL = "http://172.20.10.13:8088/confirmAppintment?token=\(token)"
        let contentValue = "body: من فضلك قم باستخدام الرابط التالي لتأكيد الحجز \(confirmURL)"
        
        let content = SendGridContent(type: .plain, value: contentValue)
        let subject = "تأكيد حجز الموعد"
        let from = SendGridEmail(email: "healthcareapp3@gmail.com")
        let to = [SendGridEmail(email: email)]
        let personalizations = SendGridPersonalization(to: to)
        let personalizationsWrapper = SendGridWrapper(personalization: [personalizations], from: from, subject: subject, content: [content])
        
        let jsonBody = try JSON(node: personalizationsWrapper.makeNode()).makeBody()
        
        let response = try drop.client.post("https://api.sendgrid.com/v3/mail/send", headers: ["Authorization": "Bearer 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", "Content-Type": "application/json"], body: jsonBody)
        
        print("\(response)")

    }
}
