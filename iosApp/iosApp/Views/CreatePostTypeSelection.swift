import SwiftUI

struct CreatePostTypeSelection: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showMusicPost = false
    @State private var showTextPost = false
    @State private var showMediaPost = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Что хотите выложить?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 40)
                    
                    VStack(spacing: 16) {
                        // Music post
                        Button(action: { showMusicPost = true }) {
                            HStack(spacing: 16) {
                                Image(systemName: "music.note")
                                    .font(.system(size: 32))
                                    .foregroundColor(Color(hex: "FF4D6A"))
                                    .frame(width: 60, height: 60)
                                    .background(Color(hex: "FF4D6A").opacity(0.1))
                                    .cornerRadius(12)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Музыка")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("Поделитесь треком")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                        }
                        
                        // Text post
                        Button(action: { showTextPost = true }) {
                            HStack(spacing: 16) {
                                Image(systemName: "text.align.left")
                                    .font(.system(size: 32))
                                    .foregroundColor(Color(hex: "FF4D6A"))
                                    .frame(width: 60, height: 60)
                                    .background(Color(hex: "FF4D6A").opacity(0.1))
                                    .cornerRadius(12)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Текстовый пост")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("Поделитесь мыслями")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                        }
                        
                        // Media post
                        Button(action: { showMediaPost = true }) {
                            HStack(spacing: 16) {
                                Image(systemName: "photo")
                                    .font(.system(size: 32))
                                    .foregroundColor(Color(hex: "FF4D6A"))
                                    .frame(width: 60, height: 60)
                                    .background(Color(hex: "FF4D6A").opacity(0.1))
                                    .cornerRadius(12)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Медиа-пост")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("Фото или видео")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationTitle("Создать пост")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Отмена") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showMusicPost) {
            MusicPostView()
        }
        .sheet(isPresented: $showTextPost) {
            TextPostView()
        }
        .sheet(isPresented: $showMediaPost) {
            MediaPostView()
        }
    }
}

struct MusicPostView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var caption = ""
    @State private var artist = ""
    @State private var title = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Исполнитель")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    TextField("", text: $artist)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Название трека")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    TextField("", text: $title)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Описание")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    TextEditor(text: $caption)
                        .frame(height: 100)
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: publishPost) {
                    Text("Опубликовать")
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
            .navigationTitle("Музыка")
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
    
    private func publishPost() {
        print("Publishing music post: artist=\(artist), title=\(title), caption=\(caption)")
        APIManager.shared.createPost(caption: caption, audio: [], artist: artist, title: title) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("Music post published: \(response)")
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    print("Error publishing music post: \(error)")
                }
            }
        }
    }
}

struct TextPostView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var caption = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Текст поста")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    TextEditor(text: $caption)
                        .frame(height: 200)
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: publishPost) {
                    Text("Опубликовать")
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
            .navigationTitle("Текстовый пост")
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
    
    private func publishPost() {
        print("Publishing text post: caption=\(caption)")
        APIManager.shared.createPost(caption: caption) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("Text post published: \(response)")
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    print("Error publishing text post: \(error)")
                }
            }
        }
    }
}

struct MediaPostView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var caption = ""
    @State private var selectedImages: [String] = []
    @State private var selectedVideos: [String] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Media selection placeholder
                VStack(spacing: 12) {
                    if selectedImages.isEmpty && selectedVideos.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("Выберите фото или видео")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(40)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                    } else {
                        // Show selected media
                        Text("Выбрано: \(selectedImages.count + selectedVideos.count) файлов")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Описание")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    TextEditor(text: $caption)
                        .frame(height: 100)
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: publishPost) {
                    Text("Опубликовать")
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
            .navigationTitle("Медиа-пост")
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
    
    private func publishPost() {
        print("Publishing media post: caption=\(caption), images=\(selectedImages), videos=\(selectedVideos)")
        APIManager.shared.createPost(caption: caption, images: selectedImages, videos: selectedVideos) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("Media post published: \(response)")
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    print("Error publishing media post: \(error)")
                }
            }
        }
    }
}
