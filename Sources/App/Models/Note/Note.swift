//
//  HandBook.swift
//  App
//
//  Created by YiYi on 2019/5/10.
//

import Vapor
import FluentMySQL
import Authentication

// 手帐本
final class Note: MySQLModel {
    var id: Int?
    var userId: User.ID
    var coverTitle: String // 封面名称
    // 255,255,255
    var coverColor: String // 封面颜色
    var fluentCreatedAt: Date?
    
    init(id: Int? = nil, coverTitle: String, userId: User.ID, coverColor: String, fluentCreatedAt: Date? = nil) {
        self.id = id
        self.userId = userId
        self.coverTitle = coverTitle
        self.coverColor = coverColor
        self.fluentCreatedAt = fluentCreatedAt
    }
}

// 实现数据库操作。如增加表字段，更新表结构
extension Note: Migration { }
// 允许从 HTTP 消息中编解码出对应数据
extension Note: Content { }
// 允许使用动态的使用在路由中定义的参数
extension Note: Parameter { }

