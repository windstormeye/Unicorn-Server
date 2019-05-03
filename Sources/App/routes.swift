import Vapor

public func routes(_ router: Router) throws {
    
    // 贴纸路由
    let stickerController = StickerController()
    router.get("stickers", use: stickerController.index)
    router.post("stickers", use: stickerController.create)
    
    // 用户路由
    let usersController = UserController()
    try router.register(collection: usersController)
}
