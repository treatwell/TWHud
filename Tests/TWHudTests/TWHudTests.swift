import XCTest
@testable import TWHud

final class TWHudTests: XCTestCase {
    func testInitialShow() {
        XCTAssertNil(TWHud.show(), "Not configured TWHud should return nil")
    }
    
    func testShowAfterConfiguring() {
        let maskImage = sampleImage!
        TWHud.configure(with: TWHud.Configuration(
            maskImage: maskImage,
            cornerRadius: 11,
            size: CGSize(width: 111, height: 111),
            fillUpTime: 0.6,
            waitTime: 0.2,
            hudBackgroundColour: .brown,
            containerBackgroundColour: .black,
            colours: [.red, .green, .blue]
        ))
        
        XCTAssertNotNil(TWHud.show(), "Configured TWHud should return shared instance")
        XCTAssertNotNil(TWHud.shared, "Configured TWHud should create shared instance")
        
        let configuration = TWHud.shared?.configuration
        XCTAssertEqual(configuration?.cornerRadius, 11, "TWHud configuration mismatch")
        XCTAssertEqual(configuration?.size, CGSize(width: 111, height: 111), "TWHud configuration mismatch")
        XCTAssertEqual(configuration?.fillUpTime, 0.6, "TWHud configuration mismatch")
        XCTAssertEqual(configuration?.waitTime, 0.2, "TWHud configuration mismatch")
        XCTAssertEqual(configuration?.hudBackgroundColour, UIColor.brown, "TWHud configuration mismatch")
        XCTAssertEqual(configuration?.containerBackgroundColour, .black, "TWHud configuration mismatch")
        XCTAssertEqual(
            configuration?.colours,
            [.red, .green, .blue],
            "Configuration should have these colours"
        )
    }
    
    func testShowInCustomView() {
        let maskImage = sampleImage!
        let hud = TWHud.showIn(
            view: UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200)),
            configuration: TWHud.Configuration(
                maskImage: maskImage,
                colours: [.yellow, .black, .purple]
            )
        )
        
        XCTAssertEqual(
            hud.configuration.colours,
            [.yellow, .black, .purple],
            "Configuration should have these colours"
        )
    }

    static var allTests = [
        ("testInitialShow", testInitialShow),
        ("testShowAfterConfiguring", testShowAfterConfiguring),
        ("testShowInCustomView", testShowInCustomView)
    ]
    
    private var sampleImage: UIImage? {
        return UIGraphicsImageRenderer(size: CGSize(width: 100, height: 100)).image { _ in
            let rect = CGRect(origin: .zero, size: CGSize(width: 100, height: 100))
            ("Sample" as NSString).draw(in: rect, withAttributes: [
                .foregroundColor: UIColor.black,
                .font: UIFont.systemFont(ofSize: 20.0),
            ])
        }
    }
}
