import CoreLocation
import Firebase
import Flutter
import GoogleMaps
import MapKit
import UIKit
import UserNotifications

#if canImport(CarPlay)
    import CarPlay
#endif

@main
@objc class AppDelegate: FlutterAppDelegate {
    var flutterEngine: FlutterEngine?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GMSServices.provideAPIKey("AIzaSyCyWXFiBQAQ6qBpb3Mq_YKta4Y_dI5c4X0")

        // 1. Configure Firebase first
        FirebaseApp.configure()

        // 2. Initialize the shared Flutter Engine
        let sharedEngine = FlutterEngine(name: "shared_engine")
        self.flutterEngine = sharedEngine  // Use the inherited 'engine' property from FlutterAppDelegate

        // 3. Start the engine shell BEFORE registration.
        // This ensures the binary messenger and task queues are ready for plugins.
        sharedEngine.run()

        // 4. Register plugins and CarPlay setup to the running engine
        GeneratedPluginRegistrant.register(with: sharedEngine)
        CarPlayManager.shared.setup(with: sharedEngine)

        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            _, _ in
        }
        application.registerForRemoteNotifications()

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // MARK: UISceneSession Lifecycle
    override func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        #if canImport(CarPlay)
            if connectingSceneSession.role == .carTemplateApplication {
                return UISceneConfiguration(
                    name: "CarPlay", sessionRole: connectingSceneSession.role)
            }
        #endif
        return UISceneConfiguration(
            name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    // MARK: - Notification Handling
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter, willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
            @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list, .sound])
    }

    override func userNotificationCenter(
        _ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if response.notification.request.content.categoryIdentifier == "booking_success"
            || response.notification.request.identifier == "booking_success"
        {
            let userInfo = response.notification.request.content.userInfo
            if let lat = userInfo["lat"] as? Double, let lng = userInfo["lng"] as? Double {
                if CarPlayManager.shared.isCarPlayActive() {
                    CarPlayManager.shared.openInCarPlayMap(lat: lat, lng: lng)
                } else {
                    CarPlayManager.shared.openGoogleMaps(lat: lat, lng: lng)
                }
            } else {
                CarPlayManager.shared.openGoogleMaps()
            }
        }
        super.userNotificationCenter(
            center, didReceive: response, withCompletionHandler: completionHandler)
    }
}

// MARK: - CarPlay Manager
#if canImport(CarPlay)
    @objcMembers
    class CarPlayManager: NSObject, CPTemplateApplicationSceneDelegate,
        CPPointOfInterestTemplateDelegate
    {
        static let shared = CarPlayManager()
        var interfaceController: CPInterfaceController?

        private let channelName = "com.onecharge.carplay"
        private var methodChannel: FlutterMethodChannel?

        func isCarPlayActive() -> Bool {
            return interfaceController != nil
        }

        func setup(with engine: FlutterEngine) {
            print("CarPlayManager: Setting up with engine: \(engine)")
            let messenger = engine.binaryMessenger
            methodChannel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
            methodChannel?.setMethodCallHandler { [weak self] (call, result) in
                print("CarPlayManager: Received call: \(call.method)")
                self?.handle(call, result: result)
            }
        }

        private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
            switch call.method {
            case "updateCarPlayUI":
                result(nil)
            case "showBookingSuccess":
                let args = call.arguments as? [String: Any]
                let lat = args?["latitude"] as? Double
                let lng = args?["longitude"] as? Double
                showBookingSuccessAlert(latitude: lat, longitude: lng)
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        func templateApplicationScene(
            _ templateApplicationScene: CPTemplateApplicationScene,
            didConnect interfaceController: CPInterfaceController
        ) {
            self.interfaceController = interfaceController
            print("CarPlayManager: Connected")

            let charging = CPListItem(
                text: "Charging Station", detailText: "Emergency charging support")
            charging.setImage(UIImage(systemName: "bolt.car.fill"))
            charging.handler = { [weak self] _, completion in
                self?.confirmBooking(category: "Charging Station")
                completion()
            }

            let flatTyre = CPListItem(text: "Flat Tyre", detailText: "Tyre repair or replacement")
            flatTyre.setImage(UIImage(systemName: "tire"))
            flatTyre.handler = { [weak self] _, completion in
                self?.confirmBooking(category: "Flat Tyre")
                completion()
            }

            let lowBattery = CPListItem(
                text: "Low Battery", detailText: "Battery boost or replacement")
            lowBattery.setImage(UIImage(systemName: "battery.25"))
            lowBattery.handler = { [weak self] _, completion in
                self?.confirmBooking(category: "Low Battery")
                completion()
            }

            let serviceSection = CPListSection(
                items: [charging, flatTyre, lowBattery], header: "Our Services",
                sectionIndexTitle: nil)
            let rootTemplate = CPListTemplate(title: "OneCharge", sections: [serviceSection])
            interfaceController.setRootTemplate(rootTemplate, animated: true, completion: nil)
        }

        func templateApplicationScene(
            _ templateApplicationScene: CPTemplateApplicationScene,
            didDisconnect interfaceController: CPInterfaceController
        ) {
            self.interfaceController = nil
            print("CarPlayManager: Disconnected")
        }

        func confirmBooking(category: String) {
            let confirmAction = CPAlertAction(title: "Confirm", style: .default) { [weak self] _ in
                self?.methodChannel?.invokeMethod(
                    "bookService", arguments: ["categoryName": category])
                self?.interfaceController?.dismissTemplate(animated: true, completion: nil)
            }
            let cancelAction = CPAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
                self?.interfaceController?.dismissTemplate(animated: true, completion: nil)
            }
            let alert = CPAlertTemplate(
                titleVariants: ["Confirm \(category)?"], actions: [confirmAction, cancelAction])
            interfaceController?.presentTemplate(alert, animated: true, completion: nil)
        }

        func showBookingSuccessAlert(latitude: Double?, longitude: Double?) {
            let lat = latitude ?? 25.1972
            let lng = longitude ?? 55.2744

            // Modal inside CarPlay
            let navigateAction = CPAlertAction(title: "Show on Map", style: .default) {
                [weak self] _ in
                self?.openInCarPlayMap(lat: lat, lng: lng)
                self?.interfaceController?.dismissTemplate(animated: true, completion: nil)
            }
            let alert = CPAlertTemplate(
                titleVariants: ["Booking Successful!"], actions: [navigateAction])
            interfaceController?.presentTemplate(alert, animated: true, completion: nil)
        }

        func openInCarPlayMap(lat: Double, lng: Double) {
            guard let interfaceController = self.interfaceController else { return }
            let poi = CPPointOfInterest(
                location: MKMapItem(
                    placemark: MKPlacemark(
                        coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng))),
                title: "Reserved Charger", subtitle: "OneCharge station",
                summary: "Drive to this location",
                detailTitle: "Ready to charge", detailSubtitle: "Booking Confirmed",
                detailSummary: "Drive to this location",
                pinImage: UIImage(systemName: "bolt.fill")
            )
            let poiTemplate = CPPointOfInterestTemplate(
                title: "Map View", pointsOfInterest: [poi], selectedIndex: 0)
            poiTemplate.pointOfInterestDelegate = self
            interfaceController.pushTemplate(poiTemplate, animated: true, completion: nil)
        }

        func pointOfInterestTemplate(
            _ poiTemplate: CPPointOfInterestTemplate, didChangeMapRegion region: MKCoordinateRegion
        ) {}
        func pointOfInterestTemplate(
            _ poiTemplate: CPPointOfInterestTemplate,
            didSelectPointOfInterest pointOfInterest: CPPointOfInterest
        ) {}
        func pointOfInterestTemplate(
            _ poiTemplate: CPPointOfInterestTemplate, didSelectButton button: CPBarButton,
            for pointOfInterest: CPPointOfInterest
        ) {}

        func openGoogleMaps(lat: Double = 25.1972, lng: Double = 55.2744) {
            let urlString = "comgooglemaps://?q=\(lat),\(lng)&directionsmode=driving"
            DispatchQueue.main.async {
                if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    let appleUrl = URL(string: "http://maps.apple.com/?q=\(lat),\(lng)")!
                    UIApplication.shared.open(appleUrl, options: [:], completionHandler: nil)
                }
            }
        }
    }
#else
    @objcMembers
    class CarPlayManager: NSObject {
        static let shared = CarPlayManager()
        func isCarPlayActive() -> Bool { return false }
        func setup(with engine: FlutterEngine) {
            print("CarPlayManager: Placeholder setup (CarPlay not available)")
        }
        func openInCarPlayMap(lat: Double, lng: Double) {}
        func openGoogleMaps(lat: Double = 25.1972, lng: Double = 55.2744) {
            let urlString = "comgooglemaps://?q=\(lat),\(lng)&directionsmode=driving"
            DispatchQueue.main.async {
                if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    let appleUrl = URL(string: "http://maps.apple.com/?q=\(lat),\(lng)")!
                    UIApplication.shared.open(appleUrl, options: [:], completionHandler: nil)
                }
            }
        }
    }
#endif

// MARK: - Scene Delegate
@objc(SceneDelegate)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene, willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let engine = appDelegate.flutterEngine {
            let controller = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
            window.rootViewController = controller
        }
        self.window = window
        window.makeKeyAndVisible()
    }
}

#if canImport(CarPlay)
    extension SceneDelegate: CPTemplateApplicationSceneDelegate {
        func templateApplicationScene(
            _ templateApplicationScene: CPTemplateApplicationScene,
            didConnect interfaceController: CPInterfaceController
        ) {
            CarPlayManager.shared.templateApplicationScene(
                templateApplicationScene, didConnect: interfaceController)
        }

        func templateApplicationScene(
            _ templateApplicationScene: CPTemplateApplicationScene,
            didDisconnect interfaceController: CPInterfaceController
        ) {
            CarPlayManager.shared.templateApplicationScene(
                templateApplicationScene, didDisconnect: interfaceController)
        }
    }
#endif
