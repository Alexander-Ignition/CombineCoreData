import Foundation

extension NSObjectProtocol {
    func apply(configure: (Self) -> Void) -> Self {
        configure(self)
        return self
    }
}
