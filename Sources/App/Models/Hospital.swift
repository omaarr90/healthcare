import Vapor
import Fluent
import Foundation


final class Hospital: Model {
    var id: Node?
    var name: String
    var lat: String
    var lon: String
    
    init(name: String, lat: String, lon: String) {
        self.id = UUID().uuidString.makeNode()
        self.name = name
        self.lat = lat
        self.lon = lon
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        lat = try node.extract("lat")
        lon = try node.extract("lon")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "lat": lat,
            "lon": lon
            ])
    }
}

extension Hospital {
    /**
     This will automatically fetch from database, using example here to load
     automatically for example. Remove on real models.
     */
//    public convenience init?(from string: String) throws {
//        self.init(content: string)
//    }
}

extension Hospital: Preparation {
    static func prepare(_ database: Database) throws {
        //
    }
    
    static func revert(_ database: Database) throws {
        //
    }
}
