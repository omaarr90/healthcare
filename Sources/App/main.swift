import Vapor
import VaporPostgreSQL

let drop = Droplet()
try drop.addProvider(VaporPostgreSQL.Provider)
drop.preparations = [Doctor.self, Symptom.self, Disease.self]
drop.view = LeafRenderer(viewsDir: drop.viewsDir)

drop.get() { req in
    return try drop.view.make("welcome")
}

drop.get("hello") { request in
    return "Hello, world!"
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
    
//    return "Hello, \(options)"
    return try drop.view.make("diagnosisResult", Node(node: ["mainDisease": mainDisease]))
}

drop.get("appointments") { request in
    return try drop.view.make("appointments")
}

drop.get("testleaf") { request in
return try drop.view.make("testLeaf")
}

drop.get("version") { request in
    if let db = drop.database?.driver as? PostgreSQLDriver {
        let version = try db.raw("SELECT version()")
        return try JSON(node: version)
    } else {
        return "No DB Connection"
    }
}


drop.resource("posts", PostController())

drop.run()
