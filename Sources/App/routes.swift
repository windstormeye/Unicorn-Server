import Vapor
import SwiftyJSON

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    router.get { req -> String in
        let dict = [
            "nick_name": "pjhubs",
            "uid": "2123313",
        ]
        let json = JSON(dict)
        return json.rawString()!
    }
    
    // Basic "Hello, world!" example
    router.get("hello") { req -> Array<User> in
        let u1 = User(id: "12345667", nickName: "PJHubs")
        let u2 = User(id: "12345667", nickName: "PJHubs")
        return [u1, u2]
    }
    
    router.post("user") { req -> Future<HTTPStatus> in
        return try req.content.decode(User.self).map(to: HTTPStatus.self) {
            print($0.id)
            print($0.nickName)
            return .ok
        }
    }

    // Example of configuring a controller
    let todoController = TodoController()
    router.get("todos", use: todoController.index)
    router.post("todos", use: todoController.create)
    router.delete("todos", Todo.parameter, use: todoController.delete)
    
    // 贴纸路由
    let stickerController = StickerController()
    router.get("stickers", use: stickerController.index)
    router.post("stickers", use: stickerController.create)
}
