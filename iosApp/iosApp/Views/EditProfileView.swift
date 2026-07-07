import SwiftUI

struct EditProfileView: View {
    @Binding var user: User?
    @Environment(\.presentationMode) var presentationMode
    @State private var username: String
    @State private var bio: String
    @State private var showPasswordChange = false
    @State private var showThemeSettings = false
    @Environment(\.colorScheme) var colorScheme
    
    init(user: Binding<User?>) {
        self._user = user
        self._username = State(initialValue: user.wrappedValue?.username ?? "")
        self._bio = State(initialValue: user.wrappedValue?.bio ?? "")
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Username
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Имя пользователя")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        TextField("", text: $username)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding()
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Bio
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Описание")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        TextEditor(text: $bio)
                            .frame(height: 100)
                            .padding()
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Settings section
                    VStack(spacing: 0) {
                        // Change password
                        Button(action: { showPasswordChange = true }) {
                            HStack {
                                Image(systemName: "lock")
                                    .foregroundColor(.gray)
                                Text("Изменить пароль")
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                        }
                        
                        Divider()
                            .padding(.leading)
                        
                        // Theme settings
                        Button(action: { showThemeSettings = true }) {
                            HStack {
                                Image(systemName: "paintbrush")
                                    .foregroundColor(.gray)
                                Text("Тема оформления")
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                        }
                    }
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Save button
                    Button(action: saveProfile) {
                        Text("Сохранить")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "FF4D6A"))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .navigationTitle("Редактировать профиль")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Отмена") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showPasswordChange) {
            ChangePasswordView()
        }
        .sheet(isPresented: $showThemeSettings) {
            ThemeSettingsView()
        }
    }
    
    private func saveProfile() {
        // TODO: Implement save to API
        presentationMode.wrappedValue.dismiss()
    }
}

struct ChangePasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Текущий пароль")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    SecureField("", text: $currentPassword)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Новый пароль")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    SecureField("", text: $newPassword)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Подтвердите пароль")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    SecureField("", text: $confirmPassword)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                Button(action: changePassword) {
                    Text("Изменить пароль")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "FF4D6A"))
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding(.top)
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Изменить пароль")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Отмена") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func changePassword() {
        guard !currentPassword.isEmpty, !newPassword.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "Заполните все поля"
            return
        }
        
        guard newPassword == confirmPassword else {
            errorMessage = "Пароли не совпадают"
            return
        }
        
        // TODO: Implement password change API call
        presentationMode.wrappedValue.dismiss()
    }
}

struct ThemeSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedTheme: String = "dark"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Dark theme
                Button(action: { selectedTheme = "dark" }) {
                    HStack {
                        Image(systemName: selectedTheme == "dark" ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(Color(hex: "FF4D6A"))
                        Text("Темная тема")
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        Spacer()
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                }
                
                Divider()
                    .padding(.leading)
                
                // Light theme
                Button(action: { selectedTheme = "light" }) {
                    HStack {
                        Image(systemName: selectedTheme == "light" ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(Color(hex: "FF4D6A"))
                        Text("Светлая тема")
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        Spacer()
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                }
            }
            .cornerRadius(12)
            .padding()
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Тема оформления")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        // TODO: Save theme preference
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
