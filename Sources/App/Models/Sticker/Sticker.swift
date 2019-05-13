//
//  Sticker.swift
//  App
//
//  Created by YiYi on 2019/4/24.
//

import FluentMySQL
import Vapor

final class Sticker: MySQLModel {
    var id: Int?
    var link: String
    /// 所属 book
    var bookId: Int

    
    /// 创建一个新的贴纸.
    init(id: Int? = nil, bookId: Int, link: String) {
        self.id = id
        self.link = link
        self.bookId = bookId
    }
}


/// 实现数据库操作。如增加表字段，更新表结构
extension Sticker: Migration { }

// 允许从 HTTP 消息中编解码出对应数据
extension Sticker: Content { }

/// 允许使用动态的使用在路由中定义的参数
extension Sticker: Parameter { }

