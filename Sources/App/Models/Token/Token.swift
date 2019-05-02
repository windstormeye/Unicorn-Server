//
//  Tokne.swift
//  App
//
//  Created by PJHubs on 2019/5/1.
//

import Foundation
import Vapor
import FluentMySQL
import Authentication


final class Token: MySQLModel {
    var id: Int?
    var userId: User.ID
    var token: String
    var fluentCreatedAt: Date?
    
    init(token: String, userId: User.ID) {
        self.token = token
        self.userId = userId
    }
}

extension Token {
    var user: Parent<Token, User> {
        return parent(\.userId)
    }
}

extension Token: BearerAuthenticatable {
    static var tokenKey: WritableKeyPath<Token, String> { return \Token.token }
}

extension Token: Migration { }
extension Token: Content { }
extension Token: Parameter { }

extension Token: Authentication.Token {
    typealias UserType = User
    typealias UserIDType = User.ID
    
    static var userIDKey: WritableKeyPath<Token, User.ID> {
        return \Token.userId
    }
}

extension Token {
    static func generate(for user: User) throws -> Token {
        let random = try CryptoRandom().generateData(count: 16)
        return try Token(token: random.base64EncodedString(), userId: user.requireID())
    }
}
