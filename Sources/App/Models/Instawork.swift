//
//  Instawork.swift
//  Instawork
//
//  Created by Trevin Wisaksana on 5/12/17.
//
//

import Foundation
import Vapor
import Fluent


struct Instawork: Model {
    
    var id: Node?
    var exists: Bool = false
    var title: String
    var body: String
    
    init(title: String, body: String) {
        self.title = title
        self.body = body
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        title = try node.extract("title")
        body = try node.extract("body")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: ["id": id,
                               "title": title,
                               "body": body])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("instaworks") { (instaworks) in
            instaworks.id()
            instaworks.string("title")
            instaworks.custom("body", type: "text")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("instaworks")
    }
    
}
