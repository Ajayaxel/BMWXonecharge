import Flutter
import GoogleMaps
import UIKit
import CarPlay
import UserNotifications
import MapKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  var flutterEngine: FlutterEngine?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyCyWXFiBQAQ6qBpb3Mq_YKta4Y_dI5c4X0")
    
    let engine = FlutterEngine(name: "shared_engine")
    engine.run()
    self.flutterEngine = engine
    
    GeneratedPluginRegistrant.register(with: engine)
    CarPlayManager.shared.setup(with: engine)
    
    UNUserNotificationCenter.current().delegate = self
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // MARK: UISceneSession Lifecycle
  override func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    if connectingSceneSession.role == .carTemplateApplication {
        return UISceneConfiguration(name: "CarPlay", sessionRole: connectingSceneSession.role)
    } else {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
  }

  // MARK: - Notification Handling
  override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
      completionHandler([.banner, .list, .sound])
  }

  override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
      if response.notification.request.content.categoryIdentifier == "booking_success" || response.notification.request.identifier == "booking_success" {
          let userInfo = response.notification.request.content.userInfo
          if let lat = userInfo["lat"] as? Double, let lng = userInfo["lng"] as? Double {
              if CarPlayManager.shared.interfaceController != nil {
                  CarPlayManager.shared.openInCarPlayMap(lat: lat, lng: lng)
              } else {
                  CarPlayManager.shared.openGoogleMaps(lat: lat, lng: lng)
              }
          } else {
              CarPlayManager.shared.openGoogleMaps()
          }
      }
      super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
  }
}

// MARK: - CarPlay Manager
@objcMembers
class CarPlayManager: NSObject, CPTemplateApplicationSceneDelegate, CPPointOfInterestTemplateDelegate {
    static let shared = CarPlayManager()
    var interfaceController: CPInterfaceController?
    
    private let channelName = "com.onecharge.carplay"
    private var methodChannel: FlutterMethodChannel?

    func setup(with engine: FlutterEngine) {
        methodChannel = FlutterMethodChannel(name: channelName, binaryMessenger: engine.binaryMessenger)
        methodChannel?.setMethodCallHandler { [weak self] (call, result) in
            self?.handle(call, result: result)
        }
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "updateCarPlayUI":
            result(nil)
        case "showBookingSuccess":
            if let args = call.arguments as? [String: Any],
               let lat = args["latitude"] as? Double,
               let lng = args["longitude"] as? Double {
                showBookingSuccessAlert(latitude: lat, longitude: lng)
            } else {
                showBookingSuccessAlert()
            }
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController
        
        // Our Services Section
        let charging = CPListItem(text: "Charging Station", detailText: "Emergency charging support")
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

        let lowBattery = CPListItem(text: "Low Battery", detailText: "Battery boost or replacement")
        lowBattery.setImage(UIImage(systemName: "battery.25"))
        lowBattery.handler = { [weak self] _, completion in
            self?.confirmBooking(category: "Low Battery")
            completion()
        }

        let mechanical = CPListItem(text: "Mechanical Issue", detailText: "Engine or mechanical repair")
        mechanical.setImage(UIImage(systemName: "wrench.and.screwdriver.fill"))
        mechanical.handler = { [weak self] _, completion in
            self?.confirmBooking(category: "Mechanical Issue")
            completion()
        }

        let towing = CPListItem(text: "Tow / Pickup", detailText: "Emergency towing service")
        towing.setImage(UIImage(systemName: "car.2.fill"))
        towing.handler = { [weak self] _, completion in
            self?.confirmBooking(category: "Tow / Pickup Required")
            completion()
        }

        let other = CPListItem(text: "Other", detailText: "Other emergency assistance")
        other.setImage(UIImage(systemName: "ellipsis.circle.fill"))
        other.handler = { [weak self] _, completion in
            self?.confirmBooking(category: "Other")
            completion()
        }

        let serviceSection = CPListSection(items: [charging, flatTyre, lowBattery, mechanical, towing, other], header: "Our Services", sectionIndexTitle: nil)
        
        let rootTemplate = CPListTemplate(title: "OneCharge", sections: [serviceSection])
        interfaceController.setRootTemplate(rootTemplate, animated: true, completion: nil)
    }

    func confirmBooking(category: String) {
        let confirmAction = CPAlertAction(title: "Confirm Booking", style: .default) { [weak self] _ in
            self?.methodChannel?.invokeMethod("bookService", arguments: ["categoryName": category])
            self?.interfaceController?.dismissTemplate(animated: true, completion: nil)
        }
        let cancelAction = CPAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.interfaceController?.dismissTemplate(animated: true, completion: nil)
        }
        
        let alert = CPAlertTemplate(
            titleVariants: ["Confirm \(category)?"],
            actions: [confirmAction, cancelAction]
        )
        interfaceController?.presentTemplate(alert, animated: true, completion: nil)
    }

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didDisconnect interfaceController: CPInterfaceController) {
        self.interfaceController = nil
    }

    private var lastBookingCoordinates: (lat: Double, lng: Double)?

    func showBookingSuccessAlert(latitude: Double? = nil, longitude: Double? = nil) {
        let lat = latitude ?? 25.1972
        let lng = longitude ?? 55.2744
        lastBookingCoordinates = (lat, lng)
        
        // Trigger a banner notification for the "top notification" feel
        let content = UNMutableNotificationContent()
        content.title = "Booking Successful!"
        content.body = "Tap to view location on CarPlay map"
        content.sound = .default
        content.userInfo = ["lat": lat, "lng": lng]
        
        let request = UNNotificationRequest(identifier: "booking_success", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)

        // Also show a CarPlay modal alert with direct action
        let navigateAction = CPAlertAction(title: "Show on Map", style: .default) { [weak self] _ in
            self?.openInCarPlayMap(lat: lat, lng: lng)
            self?.interfaceController?.dismissTemplate(animated: true, completion: nil)
        }
        let dismissAction = CPAlertAction(title: "Dismiss", style: .cancel) { [weak self] _ in
            self?.interfaceController?.dismissTemplate(animated: true, completion: nil)
        }
        
        let alert = CPAlertTemplate(titleVariants: ["Booking Successful!"], actions: [navigateAction, dismissAction])
        interfaceController?.presentTemplate(alert, animated: true, completion: nil)
    }

    func openInCarPlayMap(lat: Double, lng: Double) {
        guard let interfaceController = self.interfaceController else { return }
        
        // Since we have charging entitlement, we can use Point of Interest template to show native map on CarPlay
        let poi = CPPointOfInterest(
            location: MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng))),
            title: "Reserved Charger",
            subtitle: "OneCharge station",
            summary: "Tap to start navigation",
            detailTitle: "Ready to charge",
            detailSubtitle: "Booking Confirmed",
            detailSummary: "Drive to this location",
            pinImage: UIImage(systemName: "bolt.fill")
        )
        
        let poiTemplate = CPPointOfInterestTemplate(title: "Map View", pointsOfInterest: [poi], selectedIndex: 0)
        poiTemplate.pointOfInterestDelegate = self
        interfaceController.pushTemplate(poiTemplate, animated: true, completion: nil)
    }

    // MARK: - CPPointOfInterestTemplateDelegate
    func pointOfInterestTemplate(_ poiTemplate: CPPointOfInterestTemplate, didChangeMapRegion region: MKCoordinateRegion) {
        // Required method: handle map region changes if needed
    }
    
    func pointOfInterestTemplate(_ poiTemplate: CPPointOfInterestTemplate, didSelectPointOfInterest pointOfInterest: CPPointOfInterest) {
        // Required method: handle POI selection
    }

    func pointOfInterestTemplate(_ poiTemplate: CPPointOfInterestTemplate, didSelectButton button: CPBarButton, for pointOfInterest: CPPointOfInterest) {
        // Handle button selection (e.g., "Start Navigation")
        if let coordinate = pointOfInterest.location.placemark.location?.coordinate {
            // Initiate navigation or other actions
        }
    }

    func openGoogleMaps(lat: Double = 25.1972, lng: Double = 55.2744) {
        // If the user specially wants Google Maps on mobile, this still works
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

// MARK: - Scene Delegate
@objc(SceneDelegate)
class SceneDelegate: UIResponder, UIWindowSceneDelegate, CPTemplateApplicationSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // Use the shared engine from AppDelegate
        if let engine = appDelegate.flutterEngine {
            let controller = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
            window.rootViewController = controller
        }
        self.window = window
        window.makeKeyAndVisible()
    }

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
        CarPlayManager.shared.templateApplicationScene(templateApplicationScene, didConnect: interfaceController)
    }

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didDisconnect interfaceController: CPInterfaceController) {
        CarPlayManager.shared.templateApplicationScene(templateApplicationScene, didDisconnect: interfaceController)
    }
}
