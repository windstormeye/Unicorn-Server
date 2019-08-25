//
//  User.swift
//  App
//
//  Created by PJHubs on 2019/4/23.
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

// 实现数据库操作。如增加表字段，更新表结构
extension User: Migration { }
// 允许从 HTTP 消息中编解码出对应数据
extension User: Content { }
// 允许使用动态的使用在路由中定义的参数
extension User: Parameter { }

// User会用Token做验证。相当于User表与Token表关联
extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

// 使用结构体返回
extension User {
    // 包装用户对外的访问结构
    func toPublic() -> User.Public {
        // 调用Public。把当前对象的id和昵称传给它
        return User.Public(id: self.id!, nickname: self.nickname)
    }
}

// 定义结构体（定义Public）
extension User {
    struct Public: Content {
        let id: Int
        let nickname: String
    }
}

// 对Future的 toPublic()。
// 有时会通过User调信息，有时会通过Future调信息。但同样都是运用toPublic
// 例如 注册时会用到
extension Future where T: User {
    func toPublic() -> Future<User.Public> {
        return map(to: User.Public.self) { (user) in
            return user.toPublic()
        }
    }
}
