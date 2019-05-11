import Vapor

public func routes(_ router: Router) throws {
    try router.register(collection: StickerController())
    try router.register(collection: UserController())
    try router.register(collection: NoteController())
}
