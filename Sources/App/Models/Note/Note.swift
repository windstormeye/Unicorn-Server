//
//  HandBook.swift
//  App
//
//  Created by PJHubs on 2019/5/10.
//

import Vapor
import FluentMySQL
import Authentication


final class Note: MySQLModel {
    var id: Int?
    var userId: User.ID
    var coverTitle: String
    // 255,255,255
    var coverColor: String
    var fluentCreatedAt: Date?
    
    init(id: Int? = nil, coverTitle: String, userId: User.ID, coverColor: String, fluentCreatedAt: Date) {
        self.id = id
        self.userId = userId
        self.coverTitle = coverTitle
        self.coverColor = coverColor
        self.fluentCreatedAt = fluentCreatedAt
    }
}

extension Note: Migration { }
extension Note: Content { }
extension Note: Parameter { }

