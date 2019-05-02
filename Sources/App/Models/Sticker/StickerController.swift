//
//  StickerController.swift
//  App
//
//  Created by PJHubs on 2019/4/24.
//

import Vapor
import MySQL


/// Sticker 增删改查操作控制器
final class StickerController {

    /// 返回所有贴纸列表
    func index(_ req: Request) throws -> Future<[Sticker]> {
        return Sticker.query(on: req).all()
    }
    
    /// 保存一个编码完的贴纸入库
    func create(_ req: Request) throws -> Future<Sticker> {
        return try req.content.decode(Sticker.self).flatMap({
            return $0.save(on: req)
        })
    }

    /// 删除一个参数化的贴纸
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Sticker.self).flatMap { todo in
            return todo.delete(on: req)
            }.transform(to: .ok)
    }
}

