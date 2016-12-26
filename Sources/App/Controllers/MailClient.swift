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
        
    static func sendAppointmentConfirmation(to email: String, token: String) throws
    {
        
        let confirmURL = "http://172.20.10.13:8088/confirmAppintment?token=\(token)"
        
        let credentials = SMTPCredentials(
            user: Env.get("MAIL_USERNAME")!,
            pass: Env.get("MAIL_PASSWORD")!
        )
        let from = EmailAddress(name: "Patient Reservation System",
                                address: "healthcareapp3@gmail.com")
        let to = email
        let email: SMTP.Email = Email(from: from,
                                 to: to,
                                 subject: "تأكيد حجز الموعد",
                                 body: "من فضلك قم باستخدام الرابط التالي لتأكيد الحجز \(confirmURL)")
        
        let client = try SMTPClient<TCPClientStream>.makeSendGridClient()
        try client.send(email, using: credentials)
    }
        
}
