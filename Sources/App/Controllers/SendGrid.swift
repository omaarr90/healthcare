//
//  SendGrid.swift
//  PatientHospitalSystem
//
//  Created by Omar Alshammari on 12/27/16.
//
//

import Foundation
import Vapor

enum SendGridEmailType
{
    case plain
    case html
}
struct SendGridContent: NodeRepresentable
{
    var type: SendGridEmailType
    var value: String
    
    init(type: SendGridEmailType, value: String) {
        self.type = type
        self.value = value
    }
    
    func makeNode(context: Context) throws -> Node {
        var typeValue = ""
        switch self.type {
        case .plain:
            typeValue = "text/plain"
        default:
            typeValue = "text/html"
        }
        
        return try Node(node: [
            "type": typeValue,
            "value": value
            ])
    }
    
}

struct SendGridEmail: NodeRepresentable {
    var email: String
    
    init(email: String) {
        self.email = email
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "email": email
            ])
    }
}

struct SendGridPersonalization: NodeRepresentable {
    var to: [SendGridEmail]
    
    init(to: [SendGridEmail]) {
        self.to = to
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "to": to.makeNode()
            ])
    }
}

struct SendGridWrapper: NodeRepresentable {
    var personalization: [SendGridPersonalization]
    var from: SendGridEmail
    var subject: String
    var content: [SendGridContent]

    init(personalization: [SendGridPersonalization], from: SendGridEmail, subject: String, content: [SendGridContent]) {
        self.personalization = personalization
        self.from = from
        self.subject = subject
        self.content = content
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "personalizations": personalization.makeNode(),
            "from": from.makeNode(),
            "subject": subject,
            "content": content.makeNode()
            ])
    }
    
}
