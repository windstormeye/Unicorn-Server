//
//  StickerController.swift
//  App
//
//  Created by YiYi on 2019/4/24.
//

import Vapor
import MySQL


final class StickerController: RouteCollection {

    func boot(router: Router) throws {
        let noteRouter = router.grouped("api", "sticker")
        let stickerController = StickerController()
        
        let tokenAuthenticationMiddleware = User.tokenAuthMiddleware()
        let authedRoutes = noteRouter.grouped(tokenAuthenticationMiddleware)
        authedRoutes.post("", use: stickerController.create)
        authedRoutes.get("", use: stickerController.index)
        authedRoutes.delete("", use: stickerController.delete)
        authedRoutes.post("update", use: stickerController.update)
        authedRoutes.post("upload", use: stickerController.uploadSticker)
    }
    
    /// 返回所有贴纸列表
    func index(_ req: Request) throws -> Future<[Sticker]> {
        guard let bookId = req.query[Int.self, at: "bookId"] else {
            throw Abort(.badRequest)
        }
        
        return Sticker.query(on: req).filter(\.bookId, ._equal, bookId).all()
    }
    
    /// 保存一个编码完的贴纸入库
    func create(_ req: Request) throws -> Future<Sticker> {
//        guard let stickers = req.query[Array<Sticker>.self, at: "stickers"] else {
//            throw Abort(.badRequest)
//        }
        
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
    
    func update(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.content.decode(Sticker.self).flatMap({ updateSticker in
            let sticker = Sticker.find(updateSticker.id!, on: req)
            return sticker.flatMap({
                if $0 != nil {
                    $0!.link = updateSticker.link
                }
                let _ = $0!.update(on: req)
                return req.future(HTTPStatus.ok)
            })
        })
    }
    
    func uploadSticker(_ req: Request) throws -> Future<HTTPStatus> {
        print("uploadUserImage")
        let directory = DirectoryConfig.detect()
        let workPath = directory.workDir
        
        let name = UUID().uuidString + ".png"
        let imageFolder = "Public/images"
        let saveURL = URL(fileURLWithPath: workPath).appendingPathComponent(imageFolder, isDirectory: true).appendingPathComponent(name, isDirectory: false)
        
        return try req.content.decode(FileContent.self).map { payload in
            try payload.file.data.write(to: saveURL)
            let bookId = try req.query.get(Int.self, at: ["bookId"])
            
            _ = Sticker.query(on: req).filter(\.bookId, .equal, bookId).first().flatMap({ (sticker) -> EventLoopFuture<HTTPStatus> in
                if sticker != nil {
                    sticker!.link = saveURL.absoluteString
                    _ = sticker!.save(on: req)
                } else {
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

