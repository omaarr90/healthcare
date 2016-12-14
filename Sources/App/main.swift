import Vapor
import VaporPostgreSQL

let drop = Droplet()
try drop.addProvider(VaporPostgreSQL.Provider)
drop.view = LeafRenderer(viewsDir: drop.viewsDir)

drop.get() { req in
    return try drop.view.make("welcome")
}

drop.get("hello") { request in
    return "Hello, world!"
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
