import SwiftUI

struct AuthView: View {
    @Binding var isAuthenticated: Bool
    @State private var isLoginMode = true
    @State private var username = ""
    @State private var password = ""
    @State private var email = ""
    @State private var emoji = "😀"
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showEmojiPicker = false
    @State private var agreedToTerms = false
    @State private var selectedEmojiCategory = 0
    
    let emojiCategories = [
        "Смайлы": ["😀","�","😄","😁","😅","😂","�","�","😇","🙂","😉","😌","�😍","�","😘","😗","😙","😚","😋","😛","😜","🤪","😝","🤑","🤗","🤭","🤫","🤔","🤐","🤨","😐","😑","😶","😏","😒","�","�","�🔥","😪","😴","🥱","😷","🤒","🤕","🤢","🤮","🥴","😵","🤯","🥳","🥺","😢","😭","😤","😠","😡","🤬","💀","☠️","💩","🤡","👹","👺","👻","👽","👾","🤖","😈","👿"],
        "Жесты": ["�","👎","👏","�","🤝","💪","👋","🤞","✌️","🤟","👌","🤌","👈","👉","👆","👇","☝️","✋","🤚","🖐️","🖖","🤙","🙏","✍️","💅","🤳","💃","🕺","👯","🧏","🧎","👰","🤵","🙋","🙆","🙅","🤷","🤦","🙍","🙎","💆","💇","🧖"],
        "Животные": ["🐶","🐱","🐭","🐹","🐰","🦊","🐻","🐼","🐨","🐯","🦁","🐮","🐷","🐸","🐵","🐔","🐧","🐦","🐤","🐣","🐥","🦆","🦅","🦉","🦇","🐺","🐗","🐴","🦄","🐝","🐛","🦋","🐌","🐞","🐜","🦟","🦗","🕷️","🦂","🐢","🐍","🦎","🦖","🦕","🐙","🦑","🦐","🦞","🦀","🐡","🐠","🐟","🐬","🐳","🐋","🦈","🐊","🐅","🐆","🦓","🦍","🐘","🦏","🐪","�"]
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(hex: "FF4D6A"), Color(hex: "FF8FA3")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    // Logo
                    Text("sotspw")
                        .font(.custom("Google Sans", size: 52).weight(.semibold).italic())
                        .foregroundColor(.white)
                    
                    // Auth card
                    VStack(spacing: 20) {
                        // Mode toggle
                        HStack(spacing: 0) {
                            Button(action: { isLoginMode = true }) {
                                Text("Вход")
                                    .fontWeight(.semibold)
                                    .foregroundColor(isLoginMode ? .white : .white.opacity(0.6))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(isLoginMode ? Color.white.opacity(0.2) : Color.clear)
                            }
                            
                            Button(action: { isLoginMode = false }) {
                                Text("Регистрация")
                                    .fontWeight(.semibold)
                                    .foregroundColor(!isLoginMode ? .white : .white.opacity(0.6))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(!isLoginMode ? Color.white.opacity(0.2) : Color.clear)
                            }
                        }
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        
                        // Username
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Имя пользователя")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            
                            TextField("", text: $username)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }
                        
                        // Email (registration only)
                        if !isLoginMode {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                
                                TextField("", text: $email)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .padding()
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                            }
                        }
                        
                        // Password
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Пароль")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            
                            SecureField("", text: $password)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }
                        
                        // Emoji picker (registration only)
                        if !isLoginMode {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Выберите эмодзи")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Button(action: { showEmojiPicker.toggle() }) {
                                    HStack {
                                        Text(emoji)
                                            .font(.system(size: 32))
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(10)
                                }
                                
                                if showEmojiPicker {
                                    // Category selector
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            ForEach(Array(emojiCategories.keys.enumerated()), id: \.offset) { index, category in
                                                Button(action: {
                                                    selectedEmojiCategory = index
                                                }) {
                                                    Text(category)
                                                        .font(.caption)
                                                        .foregroundColor(selectedEmojiCategory == index ? .white : .white.opacity(0.6))
                                                        .padding(.horizontal, 12)
                                                        .padding(.vertical, 6)
                                                        .background(selectedEmojiCategory == index ? Color.white.opacity(0.3) : Color.white.opacity(0.1))
                                                        .cornerRadius(12)
                                                }
                                            }
                                        }
                                    }
                                    .padding(.bottom, 8)
                                    
                                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                        ForEach(Array(emojiCategories.values)[selectedEmojiCategory], id: \.self) { emojiOption in
                                            Button(action: {
                                                emoji = emojiOption
                                                showEmojiPicker = false
                                            }) {
                                                Text(emojiOption)
                                                    .font(.system(size: 28))
                                                    .frame(width: 40, height: 40)
                                                    .background(emoji == emojiOption ? Color.white.opacity(0.3) : Color.white.opacity(0.1))
                                                    .cornerRadius(8)
                                            }
                                        }
                                    }
                                    .padding(.vertical, 8)
                                }
                            }
                        }
                        
                        // Terms agreement (registration only)
                        if !isLoginMode {
                            HStack(spacing: 8) {
                                Button(action: { agreedToTerms.toggle() }) {
                                    Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                                        .foregroundColor(agreedToTerms ? .white : .white.opacity(0.6))
                                }
                                
                                Text("Я соглашаюсь с документами")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        
                        // Error message
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.red.opacity(0.3))
                                .cornerRadius(8)
                        }
                        
                        // Submit button
                        Button(action: handleSubmit) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text(isLoginMode ? "Войти" : "Зарегистрироваться")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .disabled(isLoading)
                    }
                    .padding(24)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(20)
                    .padding(.horizontal, 32)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func handleSubmit() {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Заполните все поля"
            return
        }
        
        if !isLoginMode {
            guard !email.isEmpty else {
                errorMessage = "Введите email"
                return
            }
            guard agreedToTerms else {
                errorMessage = "Необходимо согласиться с документами"
                return
            }
        }
        
        isLoading = true
        errorMessage = ""
        
        if isLoginMode {
            APIManager.shared.login(username: username, password: password) { result in
                DispatchQueue.main.async {
                    isLoading = false
                    switch result {
                    case .success(let response):
                        if let token = response["token"] as? String {
                            // TODO: Save token to UserDefaults
                            UserDefaults.standard.set(token, forKey: "auth_token")
                            isAuthenticated = true
                        } else if let error = response["error"] as? String {
                            errorMessage = error
                        } else {
                            // For testing - allow login without token
                            isAuthenticated = true
                        }
                    case .failure(let error):
                        errorMessage = "Ошибка: \(error.localizedDescription)"
                    }
                }
            }
        } else {
            APIManager.shared.register(username: username, password: password, emoji: emoji) { result in
                DispatchQueue.main.async {
                    isLoading = false
                    switch result {
                    case .success(let response):
                        if response["success"] as? Bool == true {
                            isLoginMode = true
                            errorMessage = ""
                        } else if let error = response["error"] as? String {
                            errorMessage = error
                        }
                    case .failure(let error):
                        errorMessage = "Ошибка: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
}

#Preview {
    AuthView(isAuthenticated: .constant(false))
}
