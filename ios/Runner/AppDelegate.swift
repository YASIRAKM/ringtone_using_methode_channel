import UIKit
import Flutter
import AudioToolbox

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "flutter_channel",
                                      binaryMessenger: controller.binaryMessenger)
    
    channel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      
      switch call.method {
      case "getRingtones":
        let ringtones = self.getAllRingtones()
        result(ringtones)
        
      case "playRingtone":
        if let args = call.arguments as? [String: Any],
           let title = args["title"] as? String {
          let success = self.playRingtoneByTitle(title)
          result(success)
        } else {
          result(false)
        }
        
      default:
        result(FlutterMethodNotImplemented)
      }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func getAllRingtones() -> [[String: String]] {
    let defaultSounds: [(name: String, soundID: UInt32)] = [
        // Classic iOS Ringtones (1000-1109 range)
        ("Complete", 1000),
        ("Bell", 1001),
        ("Bell 2", 1002),
        ("Chord", 1003),
        ("Chord 2", 1004),
        ("Cirrus", 1005),
        ("Cirrus 2", 1006),
        ("Echo", 1007),
        ("Echo 2", 1008),
        ("Halo", 1009),
        ("Halo 2", 1010),
        ("Horn", 1011),
        ("Horn 2", 1012),
        ("Note", 1013),
        ("Note 2", 1014),
        ("Popcorn", 1015),
        ("Rebound", 1016),
        ("Rebound 2", 1017),
        ("Ripple", 1018),
        ("Ripple 2", 1019),
        ("Sci-Fi", 1020),
        
        // Additional Popular Sounds (1100-1120 range)
        ("Alarm", 1100),
        ("Beep-Beep", 1101),
        ("Boing", 1102),
        ("Cricket", 1103),
        ("Digital", 1104),
        ("Drip", 1105),
        ("Duck", 1106),
        ("Glass", 1107),
        ("Heart", 1108),
        ("Magic", 1109),
        ("Old Phone", 1110),
        ("Pinball", 1111),
        ("Robot", 1112),
        ("Tink", 1113),
        ("Tweet", 1114),
        
        // iOS 15+ & Modern Sounds
        ("Ascend", 1200),
        ("Bright", 1201),
        ("Chime", 1202),
        ("Continuum", 1203),
        ("Dynamics", 1204),
        ("Fluid", 1205),
        ("Fuse", 1206),
        ("Hello", 1207),
        ("In Motion", 1208),
        ("Night Owl", 1209),
        ("Out of Tune", 1210),
        ("Pulse", 1211),
        ("Quote", 1212),
        ("Recall", 1213),
        ("Ricochet", 1214),
        ("Serenity", 1215),
        ("Signal", 1216),
        ("Sleepy", 1217),
        ("Undercurrent", 1218),
      ]
    
    var ringtones: [[String: String]] = []
    for sound in defaultSounds {
      ringtones.append([
        "title": sound.name,
        "uri": "system://\(sound.name)",
        "id": "\(sound.soundID)"
      ])
    }
    return ringtones
  }
  
  private func playRingtoneByTitle(_ title: String) -> Bool {
    let soundMapping: [String: UInt32] = [
        // Classic iOS Ringtones
        "Complete": 1000, "Bell": 1001, "Bell 2": 1002, "Chord": 1003, "Chord 2": 1004,
        "Cirrus": 1005, "Cirrus 2": 1006, "Echo": 1007, "Echo 2": 1008, "Halo": 1009,
        "Halo 2": 1010, "Horn": 1011, "Horn 2": 1012, "Note": 1013, "Note 2": 1014,
        "Popcorn": 1015, "Rebound": 1016, "Rebound 2": 1017, "Ripple": 1018, "Ripple 2": 1019,
        "Sci-Fi": 1020,
        
        // Additional Sounds
        "Alarm": 1100, "Beep-Beep": 1101, "Boing": 1102, "Cricket": 1103,
        "Digital": 1104, "Drip": 1105, "Duck": 1106, "Glass": 1107, "Heart": 1108,
        "Magic": 1109, "Old Phone": 1110, "Pinball": 1111, "Robot": 1112,
        "Tink": 1113, "Tweet": 1114,
        
        // Modern iOS 15+ Sounds
        "Ascend": 1200, "Bright": 1201, "Chime": 1202, "Continuum": 1203,
        "Dynamics": 1204, "Fluid": 1205, "Fuse": 1206, "Hello": 1207,
        "In Motion": 1208, "Night Owl": 1209, "Out of Tune": 1210, "Pulse": 1211,
        "Quote": 1212, "Recall": 1213, "Ricochet": 1214, "Serenity": 1215,
        "Signal": 1216, "Sleepy": 1217, "Undercurrent": 1218,
      ]
    
    guard let systemSoundID = soundMapping[title] else {
      return false
    }
    
    AudioServicesPlaySystemSound(systemSoundID)
    return true
  }
}
