import CoreData
import Combine
import CoreDataCombine
import XCTest

final class NSManagedObjectContext_SchedulerTests: XCTestCase {
    private var container: NSPersistentContainer!
    private var viewContext: NSManagedObjectContext { container.viewContext }
    private var backgroundContext: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        container = Schema.container

        backgroundContext = container.newBackgroundContext()
        backgroundContext.name = "com.coredata-combine.tests.background-context"
        viewContext.name = "com.coredata-combine.tests.main-context"
    }

    func testMinimumTolerance() {
        XCTAssertEqual(viewContext.minimumTolerance, backgroundContext.minimumTolerance)
        XCTAssertEqual(viewContext.minimumTolerance, ImmediateScheduler.shared.minimumTolerance)
        XCTAssertEqual(backgroundContext.minimumTolerance, ImmediateScheduler.shared.minimumTolerance)
    }

    func testNow() {
        XCTAssertEqual(viewContext.now, backgroundContext.now)
        XCTAssertEqual(viewContext.now, ImmediateScheduler.shared.now)
        XCTAssertEqual(backgroundContext.now, ImmediateScheduler.shared.now)
    }

    func testScheduleOptionsAction() {
        let expectation = self.expectation(description: "save and read book by id")

        let subscription = Deferred { () -> Just<NSManagedObjectID> in
            let book = Book(context: self.backgroundContext)
            book.name = "CoreData"
            try! self.backgroundContext.save()
            XCTAssertFalse(Thread.isMainThread, "write on background thread")
            return Just(book.objectID)
        }
        .subscribe(on: backgroundContext)
        .receive(on: viewContext)
        .map { (id: NSManagedObjectID) -> Book in
            XCTAssertTrue(Thread.isMainThread, "read on main thread")
            return self.viewContext.object(with: id) as! Book
        }
        .sink { (book: Book) in
            XCTAssertTrue(Thread.isMainThread, "receive book on main thread")
            XCTAssertEqual(book.name, "CoreData")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
            subscription.cancel()
        }
    }
}
