//
//  NoteController.swift
//  App
//
//  Created by PJHubs on 2019/5/10.
//

import Vapor
import MySQL

// 手帐本 路由控制器 增删改查操作控制器
final class NoteController: RouteCollection {
    
    // 【定义路由】定义客服端要使用的路由的格式
    func boot(router: Router) throws {
        // 与客户端相关
        let noteRouter = router.grouped("api", "note")
        let noteController = NoteController()
    
        // token鉴权
        let tokenAuthenticationMiddleware = User.tokenAuthMiddleware()
        // 验证路由
        let authedRoutes = noteRouter.grouped(tokenAuthenticationMiddleware)
        // post 发送 提交 get 获取
        // 空白是：用POST，调 http://localhost:8080/api/note
        authedRoutes.post("", use: noteController.create) // 创建手帐本
        // 用GET 调http://localhost:8080/api/note
        authedRoutes.get("", use: noteController.index) // 获取所有手帐本
        authedRoutes.get("delete", use: noteController.delete) // 删除手帐本
    }
    
    // 索引。返回所有NoteBook手帐列表（获取所有手帐本）。query查询。
    func index(_ req: Request) throws -> Future<[Note]> {
        // 把userId传进来
        guard let userId = req.query[Int.self, at: "userId"] else {
            throw Abort(.badRequest)
        }
        // 匹配：表的userId = 我传入的userId。返回所有该用户的手帐本
        return Note.query(on: req).filter(\.userId, ._equal, userId).all()
    }

    // 创建。保存一个编码完的手帐入库
    func create(_ req: Request) throws -> Future<Note> {
        // 把请求的内容 进行编解码 为 Note（按Note的字段..）
        return try req.content.decode(Note.self).flatMap({
            return $0.save(on: req)
        })
    }
    
    // 删除一个参数化的手帐（注意这里是删除，返回值为“状态”即可）
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        // 传入想删除的手帐本的bookId
        guard let bookId = req.query[Int.self, at: "bookId"] else {
            throw Abort(.badRequest)
        }
        // 匹配手帐本id
        return Note.query(on: req).filter(\.id, ._equal, bookId).delete().flatMap({
            return req.future(.ok)
        })
    }
}
