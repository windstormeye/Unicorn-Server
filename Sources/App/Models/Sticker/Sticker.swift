//
//  Sticker.swift
//  App
//
//  Created by PJHubs on 2019/4/24.
//

import FluentMySQL
import Vapor

final class Sticker: MySQLModel {
    var id: Int?
    /// x
    var x: Float
    /// y
    var y: Float
    /// width
    var w: Float
    /// height
    var h: Float
    /// 贴纸类型
    var type: StickerType
    /// 贴纸内容。
    var content: String
    /// 所属 book
    var bookId: Int

    
    /// 创建一个新的贴纸.
    init(id: Int? = nil, x: Float, y: Float, w: Float, h: Float, type: StickerType, content: String, bookId: Int) {
        self.id = id
        self.x = x
        self.y = y
        self.w = w
        self.h = h
        self.type = type
        self.bookId = bookId
        self.content = content
    }
}

extension Sticker {
    /// 贴纸类型
    enum StickerType: Int, Codable {
        case image = 0
        case icon
        case text
    }
}

/// 实现数据库操作。如增加表字段，更新表结构
extension Sticker: Migration { }

// 允许从 HTTP 消息中编解码出对应数据
extension Sticker: Content { }

/// 允许使用动态的使用在路由中定义的参数
extension Sticker: Parameter { }

