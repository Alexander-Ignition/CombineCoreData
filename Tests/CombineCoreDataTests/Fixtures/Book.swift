import CoreData

@objc(Book)
final class Book: NSManagedObject {
    @NSManaged var name: String?
}
