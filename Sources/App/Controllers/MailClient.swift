//
//  MailClient.swift
//  PatientHospitalSystem
//
//  Created by Hayes Alshammari on 3/24/1438 AH.
//
//

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
    
    static func sendTestEmail() throws {
        let credentials = SMTPCredentials(
            user: "healthcareapp3@gmail.com",
            pass: "Wadha123!@"
        )
        let from = EmailAddress(name: "Test",
                                address: "healthcareapp3@gmail.com")
        let to = "omar.alshammary@hotmail.com"
        let email: Email = Email(from: from,
                                 to: to,
                                 subject: "Vapor SMTP - Simple",
                                 body: "Hello from Vapor SMTP 👋")
        
        let client = try SMTPClient<TCPClientStream>.makeGmailClient()
        try client.send(email, using: credentials)


    }
    
    static func sendAppointmentConfirmation(to email: String, token: String) throws
    {
        
        let confirmURL = "http://172.20.10.13:8088/confirmAppintment?token=\(token)"
        
        let credentials = SMTPCredentials(
            user: "healthcareapp3@gmail.com",
            pass: "Wadha123!@"
        )
        let from = EmailAddress(name: "Test",
                                address: "healthcareapp3@gmail.com")
        let to = email
        let email: Email = Email(from: from,
                                 to: to,
                                 subject: "تأكيد حجز الموعد",
                                 body: "من فضلك قم باستخدام الرابط التالي لتأكيد الحجز \(confirmURL)")
        
        let client = try SMTPClient<TCPClientStream>.makeGmailClient()
        try client.send(email, using: credentials)
    }
        
}
