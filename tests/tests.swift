import XCTest
@testable import todocli

final class AppTests: XCTestCase {

    func testTodo() {
        var todo = Todo(id: UUID(), title: "Make coffee") 
        XCTAssert(todo.description == "\u{274C} Make coffee" && !todo.isCompleted)
        todo.isCompleted = true
        XCTAssert(todo.description == "\u{2705} Make coffee" && todo.isCompleted)
    }

    func testTodoManager() {
        let sut = TodoManager(cache: InMemoryCache())
        XCTAssert(sut.cache is InMemoryCache)
    }
    
    func testInMemoryCache() {
        reusableCacheTest(cache: InMemoryCache())
    }

    func testFileManagerCache() {
        reusableCacheTest(cache: JSONFileManagerCache())
    }

    func reusableCacheTest(cache: Cache) {
        var todos = [Todo]()
        cache.save(todos: todos)
        XCTAssert(cache.load()?.count ?? 0 == 0)
        todos.append(contentsOf: [
            Todo(id: UUID(), title: "Make coffee"),
            Todo(id: UUID(), title: "Go swimming")
        ])
        cache.save(todos: todos)
        XCTAssert(cache.load()?.count ?? 0 == 2)
    }

}
