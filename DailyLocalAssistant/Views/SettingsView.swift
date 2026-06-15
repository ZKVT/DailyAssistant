import SwiftUI

struct SettingsView: View {
    @AppStorage("preferredLocation") private var preferredLocation = "Richmond, BC"
    @AppStorage("foodPreference") private var foodPreference = "Warm and casual"
    @AppStorage("activityPreference") private var activityPreference = "Indoor first"
    @AppStorage("temperatureUnit") private var temperatureUnit = "Celsius"
    @AppStorage("appearancePreference") private var appearancePreference = "System"

    var body: some View {
        NavigationStack {
            Form {
                Section("Preferred Location") {
                    TextField("City or neighborhood", text: $preferredLocation)
                        .textInputAutocapitalization(.words)
                }

                Section("Food Preference") {
                    Picker("Food style", selection: $foodPreference) {
                        Text("Warm and casual").tag("Warm and casual")
                        Text("Healthy").tag("Healthy")
                        Text("Cafe and snacks").tag("Cafe and snacks")
                    }
                }

                Section("Activity Preference") {
                    Picker("Activity style", selection: $activityPreference) {
                        Text("Indoor first").tag("Indoor first")
                        Text("Outdoor walks").tag("Outdoor walks")
                        Text("Family friendly").tag("Family friendly")
                    }
                }

                Section("Temperature Unit") {
                    Picker("Unit", selection: $temperatureUnit) {
                        Text("Celsius").tag("Celsius")
                        Text("Fahrenheit").tag("Fahrenheit")
                    }
                }

                Section("Appearance Preference") {
                    Picker("Appearance", selection: $appearancePreference) {
                        Text("System").tag("System")
                        Text("Light").tag("Light")
                        Text("Dark").tag("Dark")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
