import Vapor
import VaporPostgreSQL

// Instance of a Droplet
let drop = Droplet()
drop.preparations += Instawork.self


do {
    // Adding the PostgreSQL provider
    try drop.addProvider(VaporPostgreSQL.Provider.self)
} catch {
    assertionFailure("Error adding provider: \(error)")
}

// MARK: Testing leaf templating
drop.get("template1") { (request) in
    return try drop.view.make("hello", Node(node: ["name" : "Trevin"]))
}

drop.get("template2", String.self) { (request, name) in
    return try drop.view.make("hello", Node(node: ["name" : name]))
}

drop.get("template3") { (request) in
    let users = try ["Trevin", "Amalie", "Wisaksana"].makeNode()
    return try drop.view.make("loop", Node(node: ["users" : users]))
}

drop.get("template4") { (request) in
    let users = try [
        ["name" : "Trevin", "email" : "trevin@trevin.com"].makeNode(),
        ["name" : "Trevin", "email" : "trevin@trevin.com"].makeNode(),
        ["name" : "Trevin", "email" : "trevin@trevin.com"].makeNode()
        ].makeNode()
    return try drop.view.make("email", Node(node: ["users" : users]))
}


drop.get("template5") { (request) in
    guard let sayHello = request.data["sayHello"]?.bool else {
        throw Abort.badRequest
    }
    return try drop.view.make("if", Node(node: ["sayHello" : sayHello.makeNode()]))
}


// MARK: Instawork's backend
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
