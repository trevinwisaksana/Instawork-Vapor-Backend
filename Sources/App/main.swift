import Vapor
import VaporPostgreSQL

// Instance of a Droplet
let drop = Droplet()
drop.preparations += Instawork.self


do {
    try drop.addProvider(VaporPostgreSQL.Provider.self)
} catch {
    assertionFailure("Error adding provider: \(error)")
}

drop.get { req in
    return try drop.view.make("welcome", [
        "message": drop.localization[req.lang, "welcome", "title"]
        ])
}


drop.get("instaworks") { (request) in
    return try drop.view.make("new")
}


drop.post("submit") { (request) in
    
    guard let title = request.formURLEncoded?["title"]?.string, let body = request.formURLEncoded?["body"]?.string else {
        return "Missing Fields"
    }
    
    var instawork = Instawork(title: title, body: body)
    try instawork.save()
    
    return try drop.view.make("new")
}


drop.resource("posts", PostController())

drop.run()
