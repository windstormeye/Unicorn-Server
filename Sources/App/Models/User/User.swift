//
//  User.swift
//  App
//
//  Created by YiYi on 2019/4/23.
//

import Vapor
import FluentMySQL
import Authentication

final class User: MySQLModel {
    var id: Int?
    var phoneNumber: String
    var nickname: String
    var password: String
    var fluentCreatedAt: Date?
    
    init(id: Int? = nil,
         phoneNumber: String,
         password: String,
         nickname: String,
         fluentCreatedAt: Date? = nil) {
        
        self.id = id
        self.nickname = nickname
        self.password = password
        self.phoneNumber = phoneNumber
        self.fluentCreatedAt = fluentCreatedAt
    }
}

extension User: Migration { }
extension User: Content { }
extension User: Parameter { }

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

extension User {
    func toPublic() -> User.Public {
        return User.Public(id: self.id!, nickname: self.nickname)
    }
}

extension User {
    struct Public: Content {
        let id: Int
        let nickname: String
    }
}

extension Future where T: User {
    func toPublic() -> Future<User.Public> {
        return map(to: User.Public.self) { (user) in
            return user.toPublic()
        }
    }
}
