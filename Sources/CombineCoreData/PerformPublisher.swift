import Combine
import CoreData

// MARK: - NSManagedObjectContext + PerformPublisher

extension NSManagedObjectContext {
    /// Asynchronously performs a given `block` on the context’s queue.
    ///
    ///     let backgroundContext: NSManagedObjectContext = // ...
    ///
    ///     backgroundContext.publisher { () -> Book in
    ///         let book = Book(context: backgroundContext)
    ///         book.name = "CoreData"
    ///         try backgroundContext.save()
    ///         return book
    ///     }.sink(receiveCompletion: { completion in
    ///         print(completion)
    ///     }, receiveValue: { (book: Book) in
    ///         print(book)
    ///     })
    ///
    /// - Parameter block: CoreData operations.
    /// - Returns: Publisher of subscriptions that execute in the context.
    public func publisher<T>(
        _ block: @escaping () throws -> T
    ) -> AnyPublisher<T, Error> {
        PerformPublisher<T>(
            managedObjectContext: self,
            block: block
        ).eraseToAnyPublisher()
    }

    /// Asynchronously performs the fetch request on the context’s queue.
    ///
    ///     let backgroundContext: NSManagedObjectContext = // ...
    ///     let fetchRequest = NSFetchRequest<Book>(entityName: "Book")
    ///
    ///     backgroundContext.fetchPublisher(fetchRequest)
    ///         .sink(receiveCompletion: { completion in
    ///             print(completion)
    ///         }, receiveValue: { (books: [Book]) in
    ///             print(books)
    ///         })
    ///
    /// - Parameter fetchRequest: A fetch request that specifies the search criteria for the fetch.
    /// - Returns: Publisher of subscriptions that execute in the context.
    public func fetchPublisher<T>(
        _ fetchRequest: NSFetchRequest<T>
    ) -> AnyPublisher<[T], Error> where T: NSFetchRequestResult {
        PerformPublisher<[T]>(managedObjectContext: self) {
            try fetchRequest.execute()
        }.eraseToAnyPublisher()
    }
}

// MARK: - Private

/// A publisher that asynchronously performs a given `block` on the context’s queue.
private struct PerformPublisher<Output>: Publisher {
    /// Untyped error is thrown from the `block`.
    typealias Failure = Error

    /// The context on which `block` will be executed.
    let managedObjectContext: NSManagedObjectContext

    /// A block to execute in `managedObjectContext`.
    let block: () throws -> Output

    func receive<S>(
        subscriber: S
    ) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = PerformSubscription<Output>(
            subscriber: AnySubscriber(subscriber),
            publisher: self)
        subscriber.receive(subscription: subscription)
    }
}

private final class PerformSubscription<Output>: Subscription, CustomStringConvertible {
    private var subscriber: AnySubscriber<Output, Error>?
    private let publisher: PerformPublisher<Output>
    var description: String { "PerformPublisher" } // for publisher print operator

    init(subscriber: AnySubscriber<Output, Error>,
         publisher: PerformPublisher<Output>
    ) {
        self.subscriber = subscriber
        self.publisher = publisher
    }

    func request(_ demand: Subscribers.Demand) {
        guard demand != .none, subscriber != nil else { return }

        publisher.managedObjectContext.perform {
            guard let subscriber = self.subscriber else { return }
            do {
                let output = try self.publisher.block()
                _ = subscriber.receive(output)
                subscriber.receive(completion: .finished)
            } catch {
                subscriber.receive(completion: .failure(error))
            }
        }
    }

    func cancel() {
        subscriber = nil
    }
}
