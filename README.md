# 🚜 CombineCoreData

[![SPM compatible](https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat)](https://swift.org/package-manager)
[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://github.com/Alexander-Ignition/OSLogging/blob/master/LICENSE)


## Features

- [x] NSManagedObjectContext + Scheduler
- [ ] NSAsynchronousFetchRequest + Publisher


## Instalation

Add dependency to `Package.swift`...

```swift
.package(url: "https://github.com/Alexander-Ignition/CombineCoreData", from: "0.0.2"),
```

... and your target

```swift
.target(name: "ExampleApp", dependencies: ["CombineCoreData"]),
```

## NSManagedObjectContext + Scheduler

```swift
import Combine
import CoreData
import CombineCoreData

let subscription = Deferred {
    // Write `Book` on background thread in `backgroundContext`
    Result<NSManagedObjectID, Error> {
        let book = Book(context: self.backgroundContext)
        book.name = "CoreData"
        try self.backgroundContext.save()
        return book.objectID
    }.publisher
}
.subscribe(on: backgroundContext)
.receive(on: viewContext)
.map { (id: NSManagedObjectID) -> Book in
    // Read `Book` on main thread in `viewContext`.
    return self.viewContext.object(with: id) as! Book
}
.sink(
    receiveCompletion: { completion in
        print(completion)
    },
    receiveValue: { (book: Book) in
        // Receive `Book` on main thread in `viewContext`
        print(book)
    })
```
