import FluentSQLite
import Vapor

/// Called before your application initializes.
/// 应用初始化完会被调用
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // 首先注册数据库
    try services.register(FluentSQLiteProvider())

    // 注册路由到路由器中进行管理
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // 注册中间件
    // 创建一个中间件配置文件
    var middlewares = MiddlewareConfig()
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    // 错误中间件。捕获错误并转化到 HTTP 返回体中
    middlewares.use(ErrorMiddleware.self)
    services.register(middlewares)

    // 配置 SQLite 数据库
    let sqlite = try SQLiteDatabase(storage: .memory)

    // 注册 SQLite 数据库配置文件到数据库配置中心
    var databases = DatabasesConfig()
    databases.add(database: sqlite, as: .sqlite)
    services.register(databases)

    // 配置迁移文件。相当于注册表
    var migrations = MigrationConfig()
    migrations.add(model: Todo.self, database: .sqlite)
    migrations.add(model: Sticker.self, database: .sqlite)
    services.register(migrations)
}
