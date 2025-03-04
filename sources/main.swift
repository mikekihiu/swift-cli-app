import Foundation

// * Create the `Todo` struct.
// * Ensure it has properties: id (UUID), title (String), and isCompleted (Bool).
struct Todo: CustomStringConvertible, Codable {

    let id: UUID
    let title: String
    var isCompleted: Bool = false
    
    var description: String {
        "\(isCompleted ? "\u{2705}" : "\u{274C}") \(title)"
    }
}

// Create the `Cache` protocol that defines the following method signatures:
//  `func save(todos: [Todo])`: Persists the given todos.
//  `func load() -> [Todo]?`: Retrieves and returns the saved todos, or nil if none exist.
protocol Cache {
    func save(todos: [Todo])
    func load() -> [Todo]?
}

// `FileSystemCache`: This implementation should utilize the file system
// to persist and retrieve the list of todos.
// Utilize Swift's `FileManager` to handle file operations.
final class JSONFileManagerCache: Cache {
    
    private let fileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("todos.json")
    
    func save(todos: [Todo]) {
        guard let fileUrl, let data = try? JSONEncoder().encode(todos) else {
            return
        }
        try? data.write(to: fileUrl)
    }
    
    func load() -> [Todo]? {
        guard let fileUrl, let data = try? Data(contentsOf: fileUrl) else {
            return nil
        }
        return try? JSONDecoder().decode([Todo].self, from: data)
    }
}

// `InMemoryCache`: : Keeps todos in an array or similar structure during the session.
// This won't retain todos across different app launches,
// but serves as a quick in-session cache.
final class InMemoryCache: Cache {
    
    private var todos: [Todo]?
    
    func save(todos: [Todo]) {
        self.todos = todos
    }

    func load() -> [Todo]? {
        todos
    }
}

// The `TodosManager` class should have:
// * A function `func listTodos()` to display all todos.
// * A function named `func addTodo(with title: String)` to insert a new todo.
// * A function named `func toggleCompletion(forTodoAtIndex index: Int)`
//   to alter the completion status of a specific todo using its index.
// * A function named `func deleteTodo(atIndex index: Int)` to remove a todo using its index.
final class TodoManager {

    let cache: Cache
    var todos = [Todo]()

    init(cache: Cache) {
        self.cache = cache
        if let savedTodos = cache.load() {
            self.todos = savedTodos
        }
    }

    func listTodos() {
        print(todos.isEmpty ? "\nThere are no Todos at the moment. Please add some" : "\n\u{1F4DD} Your Todos:")
        todos.enumerated().forEach { item in
            print("\(item.offset + 1). \(item.element.description)")
        }
    }

    func addTodo(with title: String) {
        todos.append(Todo(id: UUID(), title: title))
        cache.save(todos: todos)
        print("\n\u{1F4CC} Todo added!")
    }

    func toggleCompletion(forTodoAtIndex index: Int) {
        if index < 1 || todos.count < index {
            print("\n\u{2757} Invalid todo number. Please try again")
            return
        }
        todos[index-1].isCompleted.toggle()
        cache.save(todos: todos)
        print("\n\u{1F504} Todo completion status toggled!")
    }

    func deleteTodo(atIndex index: Int) {
        if index < 1 || todos.count < index {
            print("\n\u{2757} Invalid todo number. Please try again")
            return
        }
        todos.remove(at: index-1)
        cache.save(todos: todos)
        print("\n\u{1F5D1} Todo deleted!")
    }
}


// * The `App` class should have a `func run()` method, this method should perpetually
//   await user input and execute commands.
//  * Implement a `Command` enum to specify user commands. Include cases
//    such as `add`, `list`, `toggle`, `delete`, and `exit`.
//  * The enum should be nested inside the definition of the `App` class
final class App {

    let todoManager: TodoManager
    
    init(todoManager: TodoManager) {
        self.todoManager = todoManager
    }

    func run() {
        var state: Command? = nil
        
        print("\u{1F31F} Welcome to Todo CLI \u{1F31F}")

        while state != .exit {
            print("\nWhat would you like to do? (add, list, toggle, delete, exit): ", terminator: "")
            let input = readLine()
            if let input, let command = Command(rawValue: input) {
                switch command {
                case .add:
                    performAdd()
                case .delete:
                    performDelete()
                case .exit:
                    performExit()
                case .list:
                    performList()
                case .toggle:
                    performToggle()
                }
                state = command
            } else {
                print("\n\u{2757} Invalid command. Please try again")
            }
        }
    }
    
    private func performAdd() {
        print("\nEnter todo title: ", terminator: "")
        if let todoName = readLine() {
            todoManager.addTodo(with: todoName)
        }
    }
    
    private func performDelete() {
        performList()
        if todoManager.todos.isEmpty { return }
        print("\nEnter the number of todo to delete: ", terminator: "")
        if let strNumber = readLine(), let number = Int(strNumber) {
            todoManager.deleteTodo(atIndex: number)
        } else {
            print("\n\u{2757} Invalid todo number. Please try again")
        }
    }
    
    private func performExit() {
        print("\n\u{1F44B} Thanks for using Todo CLI. See you next time!\n")
    }
    
    private func performList() {
        todoManager.listTodos()
    }
    
    private func performToggle() {
        performList()
        if todoManager.todos.isEmpty { return }
        print("\nEnter the number of todo to toggle: ", terminator: "")
        if let strNumber = readLine(), let number = Int(strNumber) {
            todoManager.toggleCompletion(forTodoAtIndex: number)
        } else {
            print("\n\u{2757} Invalid todo number. Please try again")
        }
    }

    private enum Command: String {
        case add, list, toggle, delete, exit
    }
}


let cache = JSONFileManagerCache()//InMemoryCache()
let todoManager = TodoManager(cache: cache)
let app = App(todoManager: todoManager)
app.run()
