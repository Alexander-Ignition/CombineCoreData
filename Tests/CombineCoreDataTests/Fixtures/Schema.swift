import CoreData

enum Schema {
    static var container: NSPersistentContainer {
        NSPersistentContainer(name: "Books", managedObjectModel: model).apply {
            $0.persistentStoreDescriptions.forEach {
                $0.type = NSInMemoryStoreType
            }
            $0.loadPersistentStores { storeDescription, error in
                precondition(error == nil, "\(storeDescription), \(error!)")
            }
        }
    }

    private static let model = NSManagedObjectModel().apply {
        $0.entities = [book]
    }

    private static let book = NSEntityDescription().apply {
        $0.name = "Book"
        $0.managedObjectClassName = $0.name
        $0.properties = [
            NSAttributeDescription().apply {
                $0.attributeType = .stringAttributeType
                $0.name = "name"
            }
        ]
    }
}
