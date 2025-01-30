enum SecureConfiguration {
    static var visualRecognitionAPIKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "IBM Watson Visual Recognition API Key") as? String else {
            fatalError("API Key not found in Info.plist")
        }
        return key
    }
}
