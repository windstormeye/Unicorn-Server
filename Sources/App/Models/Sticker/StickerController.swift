//
//  StickerController.swift
//  App
//
//  Created by YiYi on 2019/4/24.
//

import Vapor
import MySQL

// Sticker 增删改查操作控制器
final class StickerController: RouteCollection {

    // 【定义路由】定义客服端要使用的路由的格式
    func boot(router: Router) throws {
        // 与客户端相关
        let noteRouter = router.grouped("api", "sticker")
        let stickerController = StickerController()
        // token鉴权
        let tokenAuthenticationMiddleware = User.tokenAuthMiddleware()
        // 验证路由
        let authedRoutes = noteRouter.grouped(tokenAuthenticationMiddleware)
        // post 发送 提交 get 获取
        authedRoutes.post("", use: stickerController.create)
        authedRoutes.get("", use: stickerController.index)
        authedRoutes.delete("", use: stickerController.delete)
        // update 更新 upload 上传
        authedRoutes.post("update", use: stickerController.update)
        authedRoutes.post("upload", use: stickerController.uploadSticker)
    }
    
    /// 返回所有贴纸列表。query查询。
    func index(_ req: Request) throws -> Future<[Sticker]> {
        guard let bookId = req.query[Int.self, at: "bookId"] else {
            throw Abort(.badRequest)
        }
        
        return Sticker.query(on: req).filter(\.bookId, ._equal, bookId).all()
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
    
    // 更新贴纸表的link。地址-已完成的手帐内容
    func update(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.content.decode(Sticker.self).flatMap({ updateSticker in
            let sticker = Sticker.find(updateSticker.id!, on: req)
            // 找到后把新的赋值给旧的
            return sticker.flatMap({
                if $0 != nil {
                    $0!.link = updateSticker.link
                }
                // 执行更新
                let _ = $0!.update(on: req)
                return req.future(HTTPStatus.ok)
            })
        })
    }
    
    // 上传贴纸->上传手帐本整页内容
    func uploadSticker(_ req: Request) throws -> Future<HTTPStatus> {
        let directory = DirectoryConfig.detect()
        let workPath = directory.workDir
        
        // 文件名 UUID随机字符
        let name = UUID().uuidString + ".png"
        let imageFolder = "Public/images"
        // URL统一资源定位符（文件夹）
        let saveURL = URL(fileURLWithPath: workPath).appendingPathComponent(imageFolder, isDirectory: true).appendingPathComponent(name, isDirectory: false)
        
        // 根据bookId更新手帐本内容
        return try req.content.decode(FileContent.self).map { payload in
            try payload.file.data.write(to: saveURL)
            let bookId = try req.query.get(Int.self, at: ["bookId"])
            // 存在该bookId就更新
            _ = Sticker.query(on: req).filter(\.bookId, .equal, bookId).first().flatMap({ (sticker) -> EventLoopFuture<HTTPStatus> in
                if sticker != nil {
                    sticker!.link = saveURL.absoluteString
                    _ = sticker!.save(on: req)
                } else { // 不存在就创建
                    let sticker = Sticker(bookId: bookId,
                                          link: saveURL.absoluteString)
                    let _ = sticker.save(on: req)
                }
                // TODO: 有问题，应该在 `flatMap` 内处理完数据后返回
                return req.future(.ok)
            })
        
            return .ok
        }
    }
}

struct FileContent: Content {
    var file: File
}

