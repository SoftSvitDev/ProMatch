import FirebaseRemoteConfig

enum RemoteConfigKey: String {
    case gq92isvrep // privacy
    case okq89on7 // app store url
    case fe3xr4io0q8yllz2 // terms_url
    case kdf9ich54479js // cloak
    case l7jwboe8dfmtvk // cloack switch
    case xl9pq9xekciya3pk // ip location
    case wf78tgoc0oxkbw // user agent
}

protocol RemoteConfigProtocol {
    func fetch(completion: @escaping (Bool) -> Void)
    func getString(for key: RemoteConfigKey) -> String
    func getJSON<T: Decodable>(for key: RemoteConfigKey, as type: T.Type) -> T?
}

final class RemoteConfigService: RemoteConfigProtocol {
    static let shared = RemoteConfigService()
    private enum Defaults {
        static let cbfgweksOaL = ""
        static let ghsjdjeoQsawpx = ""
        static let slwoepfjKA = ""
        static let sdskskLasqpxMsd = ""
        static let zaqfldsk = ""
        static let zpslvmWq = ""
    }
    
    private let remoteConfig: RemoteConfig
    
    init(remoteConfig: RemoteConfig = RemoteConfig.remoteConfig()) {
        self.remoteConfig = remoteConfig
        setup()
    }
    
    private func setup() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0

        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(makeDefaults())
    }
    
    private func makeDefaults() -> [String: NSObject] {
        return [
            RemoteConfigKey.gq92isvrep.rawValue: Defaults.cbfgweksOaL as NSObject,
            RemoteConfigKey.okq89on7.rawValue: Defaults.ghsjdjeoQsawpx as NSObject,
            RemoteConfigKey.fe3xr4io0q8yllz2.rawValue: Defaults.slwoepfjKA as NSObject,
            RemoteConfigKey.l7jwboe8dfmtvk.rawValue: Defaults.sdskskLasqpxMsd as NSObject,
            RemoteConfigKey.xl9pq9xekciya3pk.rawValue: Defaults.zaqfldsk as NSObject,
            RemoteConfigKey.wf78tgoc0oxkbw.rawValue: Defaults.zpslvmWq as NSObject
        ]
    }
    
    func fetch(completion: @escaping (Bool) -> Void) {
        remoteConfig.fetchAndActivate() { result, error in
            if let error = error {
                print("RemoteConfig error: \(error)")
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func getString(for key: RemoteConfigKey) -> String {
        return remoteConfig[key.rawValue].stringValue
    }
    
    func getJSON<T: Decodable>(for key: RemoteConfigKey, as type: T.Type) -> T? {
        let rawString = remoteConfig[key.rawValue].stringValue
        guard
            !rawString.isEmpty,
            let data = rawString.data(using: .utf8)
        else {
            return nil
        }
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            print("RemoteConfig JSON decode error for key '\(key.rawValue)': \(error)")
            return nil
        }
    }
}
