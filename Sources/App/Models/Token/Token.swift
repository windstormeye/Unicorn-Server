//
//  Token.swift
//  App
//
//  Created by YiYi on 2019/5/1.
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

// 实现 `Authentication.Token` 协议，使 `Token` 成为 `Authentication.Token`
extension Token: Authentication.Token {
    // 指定协议中的 `UserType` 为自定义的 `User`
    typealias UserType = User
    // 置顶协议中的 `UserIDType` 为自定义的 `User.ID`
    typealias UserIDType = User.ID
    
    // `token` 与 `user` 进行绑定
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
