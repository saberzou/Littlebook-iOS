import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: ContentStore
    
    var body: some View {
        NavigationStack {
            List {
                // Account Section
                Section {
                    NavigationLink {
                        AccountLoginView()
                    } label: {
                        Label("Sign In", systemImage: "person.circle")
                    }
                } header: {
                    Text("Account")
                }
                
                // Subscription Section
                Section {
                    NavigationLink {
                        SubscriptionView()
                    } label: {
                        HStack {
                            Label("Premium", systemImage: "crown.fill")
                            Spacer()
                            Text("Unlock All")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                    
                    Button {
                        // Restore purchases
                    } label: {
                        Label("Restore Purchases", systemImage: "arrow.clockwise")
                    }
                } header: {
                    Text("Subscription")
                }
                
                // App Settings
                Section {
                    HStack {
                        Label("Notifications", systemImage: "bell.badge")
                        Spacer()
                        Toggle("", isOn: .constant(true))
                    }
                } header: {
                    Text("Preferences")
                }
                
                // About Section
                Section {
                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }
                    
                    Link(destination: URL(string: "https://example.com/terms")!) {
                        Label("Terms of Service", systemImage: "doc.text")
                    }
                    
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Placeholder views for account and subscription
struct AccountLoginView: View {
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        Form {
            Section {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textContentType(.password)
            } header: {
                Text("Login Credentials")
            }
            
            Section {
                Button("Sign In") {
                    // Handle sign in
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .fontWeight(.semibold)
                
                Button("Create Account") {
                    // Handle account creation
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            
            Section {
                Button("Forgot Password?") {
                    // Handle password reset
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Sign In")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SubscriptionView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                        .padding(.top, 40)
                    
                    Text("Premium")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Unlock the full experience")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Features
                VStack(alignment: .leading, spacing: 16) {
                    FeatureRow(icon: "book.fill", title: "Unlimited Books", description: "Access our entire collection")
                    FeatureRow(icon: "photo.fill", title: "HD Wallpapers", description: "Download high-resolution images")
                    FeatureRow(icon: "sparkles", title: "Ad-Free", description: "Enjoy without interruptions")
                    FeatureRow(icon: "arrow.down.circle.fill", title: "Offline Access", description: "Save content for later")
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 24)
                
                // Pricing Options
                VStack(spacing: 12) {
                    PricingOption(title: "Annual", price: "$29.99/year", savings: "Save 50%", isSelected: true)
                    PricingOption(title: "Monthly", price: "$4.99/month", savings: nil, isSelected: false)
                }
                .padding(.horizontal, 20)
                
                // Subscribe Button
                Button {
                    // Handle subscription
                } label: {
                    Text("Start Free Trial")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.orange)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                Text("7-day free trial, then $29.99/year")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 40)
            }
        }
        .navigationTitle("Go Premium")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.orange)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct PricingOption: View {
    let title: String
    let price: String
    let savings: String?
    let isSelected: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(price)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if let savings = savings {
                Text(savings)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(8)
            }
            
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? .orange : .secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.orange : Color.secondary.opacity(0.3), lineWidth: 2)
        )
    }
}

#Preview {
    SettingsView()
        .environmentObject(ContentStore())
}
