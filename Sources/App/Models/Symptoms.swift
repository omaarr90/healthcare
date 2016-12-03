import Vapor
import Fluent
import Foundation

final class Symptoms: Model {
    var id: Node?
    var disease: Disease
    var symptomsList: [String]
    
    init(symptomsList: [String], disease: Disease) {
        self.id = UUID().uuidString.makeNode()
        self.symptomsList = symptomsList
        self.disease = disease
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        symptomsList = try node.extract("symptomsList")
        disease = try node.extract("disease")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "symptomsList": symptomsList.makeNode(),
            "disease": disease.makeNode()
            ])
    }
}

extension Symptoms {
    /**
     This will automatically fetch from database, using example here to load
     automatically for example. Remove on real models.
     */
//    public convenience init?(from string: String) throws {
//        self.init(content: string)
//    }
}

extension Symptoms: Preparation {
    static func prepare(_ database: Database) throws {
        //
    }
    
    static func revert(_ database: Database) throws {
        //
    }
}
