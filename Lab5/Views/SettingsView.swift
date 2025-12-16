import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: AppSettings
    @Environment(\.dismiss) var dismiss
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: settings.isDarkMode ?
                        settings.selectedTheme.darkGradientColors :
                        settings.selectedTheme.gradientColors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Секція теми
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "paintpalette.fill")
                                    .foregroundColor(settings.selectedTheme.primaryColor)
                                    .font(.system(size: settings.fontSize.headlineSize))
                                Text("Кольорова тема")
                                    .font(.system(size: settings.fontSize.headlineSize))
                                    .bold()
                                    .foregroundColor(settings.isDarkMode ? .white : .primary)
                            }
                            
                            Picker("Тема", selection: $settings.selectedTheme) {
                                ForEach(ColorTheme.allCases, id: \.self) { theme in
                                    HStack {
                                        Circle()
                                            .fill(theme.primaryColor)
                                            .frame(width: 20, height: 20)
                                        Text(theme.rawValue)
                                            .font(.system(size: settings.fontSize.bodySize))
                                            .foregroundColor(settings.isDarkMode ? .white : .primary)
                                    }
                                    .tag(theme)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding()
                            .background(settings.isDarkMode ? Color.black.opacity(0.3) : Color.white.opacity(0.8))
                            .cornerRadius(12)
                        }
                        .padding()
                        .background(settings.isDarkMode ? Color.black.opacity(0.2) : Color.white.opacity(0.5))
                        .cornerRadius(16)
                        
                        // Секція розміру шрифту
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "textformat.size")
                                    .foregroundColor(settings.selectedTheme.primaryColor)
                                    .font(.system(size: settings.fontSize.headlineSize))
                                Text("Розмір шрифту")
                                    .font(.system(size: settings.fontSize.headlineSize))
                                    .bold()
                                    .foregroundColor(settings.isDarkMode ? .white : .primary)
                            }
                            
                            Picker("Розмір", selection: $settings.fontSize) {
                                ForEach(FontSize.allCases, id: \.self) { size in
                                    Text(size.rawValue)
                                        .font(.system(size: size.bodySize))
                                        .tag(size)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding()
                            .background(settings.isDarkMode ? Color.black.opacity(0.3) : Color.white.opacity(0.8))
                            .cornerRadius(12)
                            
                            Text("Приклад тексту: Курс Bitcoin")
                                .font(.system(size: settings.fontSize.bodySize))
                                .foregroundColor(settings.isDarkMode ? .white : .primary)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(settings.isDarkMode ? Color.black.opacity(0.3) : Color.white.opacity(0.8))
                                .cornerRadius(12)
                        }
                        .padding()
                        .background(settings.isDarkMode ? Color.black.opacity(0.2) : Color.white.opacity(0.5))
                        .cornerRadius(16)
                        
                        // Секція темного режиму
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: settings.isDarkMode ? "moon.fill" : "sun.max.fill")
                                    .foregroundColor(settings.selectedTheme.primaryColor)
                                    .font(.system(size: settings.fontSize.headlineSize))
                                Text("Темний режим")
                                    .font(.system(size: settings.fontSize.headlineSize))
                                    .bold()
                                    .foregroundColor(settings.isDarkMode ? .white : .primary)
                                
                                Spacer()
                                
                                Toggle("", isOn: $settings.isDarkMode)
                                    .labelsHidden()
                                    .tint(settings.selectedTheme.primaryColor)
                            }
                            .padding()
                            .background(settings.isDarkMode ? Color.black.opacity(0.3) : Color.white.opacity(0.8))
                            .cornerRadius(12)
                        }
                        .padding()
                        .background(settings.isDarkMode ? Color.black.opacity(0.2) : Color.white.opacity(0.5))
                        .cornerRadius(16)
                        
                        // Секція відображення
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "eye.fill")
                                    .foregroundColor(settings.selectedTheme.primaryColor)
                                    .font(.system(size: settings.fontSize.headlineSize))
                                Text("Відображення")
                                    .font(.system(size: settings.fontSize.headlineSize))
                                    .bold()
                                    .foregroundColor(settings.isDarkMode ? .white : .primary)
                            }
                            
                            Toggle(isOn: $settings.showPriceInPicker) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Показувати ціну в списку")
                                        .font(.system(size: settings.fontSize.bodySize))
                                        .foregroundColor(settings.isDarkMode ? .white : .primary)
                                    Text("Відображати поточну ціну біля назви криптовалюти")
                                        .font(.system(size: settings.fontSize.captionSize))
                                        .foregroundColor(settings.isDarkMode ? .white.opacity(0.7) : .secondary)
                                }
                            }
                            .tint(settings.selectedTheme.primaryColor)
                            .padding()
                            .background(settings.isDarkMode ? Color.black.opacity(0.3) : Color.white.opacity(0.8))
                            .cornerRadius(12)
                        }
                        .padding()
                        .background(settings.isDarkMode ? Color.black.opacity(0.2) : Color.white.opacity(0.5))
                        .cornerRadius(16)
                        
                        // Кнопка скидання налаштувань
                        Button(action: {
                            resetSettings()
                        }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: settings.fontSize.headlineSize))
                                Text("Скинути налаштування")
                                    .font(.system(size: settings.fontSize.headlineSize))
                                    .bold()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.gray, .gray.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: .gray.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // Кнопка видалення збережених даних
                        Button(action: {
                            showDeleteConfirmation = true
                        }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: settings.fontSize.headlineSize))
                                Text("Видалити збережені дані")
                                    .font(.system(size: settings.fontSize.headlineSize))
                                    .bold()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.red, .red.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: .red.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                    .padding()
                }
            }
            .navigationTitle("Налаштування")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                    .foregroundColor(settings.selectedTheme.primaryColor)
                    .font(.system(size: settings.fontSize.bodySize))
                    .bold()
                }
            }
            .alert("Видалити збережені дані?", isPresented: $showDeleteConfirmation) {
                Button("Скасувати", role: .cancel) { }
                Button("Видалити", role: .destructive) {
                    _ = FileManagerService.shared.deleteCoinsFile()
                }
            } message: {
                Text("Це видалить локально збережені дані криптовалют. При наступному запуску дані будуть завантажені з API.")
            }
        }
    }
    
    func resetSettings() {
        settings.selectedTheme = .blue
        settings.fontSize = .medium
        settings.isDarkMode = false
        settings.showPriceInPicker = true
    }
}
