
import SwiftUI
import UIKit
import UniformTypeIdentifiers
import PhotosUI

struct Preset: Codable, Equatable {
    var carrier = "Milkbunga"
    var clock = "9:41"
    var battery = 85
    var wifi = true
    var cellular = true
    var label = "Milkbunga"
    var website = "https://example.com"
    var appearance = "Sistema"
}
struct ExportFile: FileDocument {
    static var readableContentTypes: [UTType] { [.data, .json] }
    var data: Data
    init(data: Data) { self.data = data }
    init(configuration: ReadConfiguration) throws { data = configuration.file.regularFileContents ?? Data() }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper { FileWrapper(regularFileWithContents: data) }
}
@main struct MilkbungaMobile: App {
    var body: some Scene { WindowGroup { Dashboard() } }
}
struct Dashboard: View {
    @AppStorage("preset") private var saved = Data()
    @State private var preset = Preset()
    @State private var iconData: Data?
    @State private var photo: PhotosPickerItem?
    @State private var export: ExportFile?
    @State private var exportType: UTType = .json
    @State private var exportName = "Milkbunga"
    @State private var exporting = false
    @State private var notice = ""
    @State private var alert = false
    @State private var controls = Set(["wifi", "bluetooth"])
    @State private var importing = false
    private let profileType = UTType(filenameExtension: "mobileconfig") ?? .data
    var body: some View {
        TabView {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Image(systemName: "iphone.gen3").font(.system(size: 40, weight: .light))
                                Spacer()
                                Text("NATIVO").font(.caption.bold()).padding(8).background(.white.opacity(0.16), in: Capsule())
                            }
                            Text("Milkbunga").font(.system(size: 37, weight: .bold, design: .rounded))
                            Text("Seu iPhone, seu estilo.").font(.headline)
                            Text(UIDevice.current.model + " • iOS " + UIDevice.current.systemVersion).font(.subheadline)
                        }.frame(maxWidth: .infinity, alignment: .leading).padding(24)
                         .foregroundStyle(.white)
                         .background(LinearGradient(colors: [.indigo, .blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 30))
                        Text("Personalização").font(.title2.bold())
                        link("Temas e ícones", "paintbrush.pointed", "Crie atalhos web com ícone próprio", .purple) { themes }
                        link("Barra de status", "wifi", "Editor de prévia", .blue) { status }
                        link("Central de Controle", "switch.2", "Organize uma prévia visual", .mint) { controlCenter }
                        link("SpringBoard", "square.grid.2x2", "Ajustes disponíveis no sistema", .orange) { restricted("SpringBoard") }
                        link("Opções internas", "gearshape.2", "Compatibilidade e limites", .gray) { restricted("Opções internas") }
                        link("Configuração", "slider.horizontal.3", "Preferências e informações", .indigo) { restricted("Configuração") }
                    }.padding()
                }.background(Color(uiColor: .systemGroupedBackground)).navigationTitle("Início")
            }.tabItem { Label("Início", systemImage: "house") }
            NavigationStack { Form {
                Section("Explore") {
                    link("Temas", "paintpalette", "Crie um Web Clip", .pink) { themes }
                    link("Status", "iphone", "Personalize a prévia", .blue) { status }
                    link("Controles", "switch.2", "Monte uma composição", .mint) { controlCenter }
                }
                Section("Projeto") {
                    Link("Repositório original", destination: URL(string: "https://github.com/sam-20009/Milkbunga-ipa-to-run-on-iOS")!)
                }
            }.navigationTitle("Explorar") }.tabItem { Label("Explorar", systemImage: "safari") }
            NavigationStack { Form {
                Section("Aparência") {
                    Picker("Tema", selection: $preset.appearance) {
                        ForEach(["Sistema", "Claro", "Escuro"], id: \.self) { Text($0) }
                    }
                }
                Section("Aplicar") {
                    Button("Exportar perfil de atalho web") { createProfile() }
                    Button("Exportar projeto JSON") { savePreset() }
                    Button("Importar projeto JSON") { importing = true }
                    Button("Redefinir preferências", role: .destructive) { preset = Preset(); iconData = nil }
                }
                Section("Importante") {
                    Text("O perfil exportado requer instalação manual em Ajustes. As prévias não alteram a barra de status real, a Central de Controle ou o SpringBoard. Nenhuma restauração de backup é executada.")
                }
            }.navigationTitle("Ajustes") }.tabItem { Label("Ajustes", systemImage: "gearshape") }
        }
        .tint(.indigo)
        .preferredColorScheme(preset.appearance == "Claro" ? .light : preset.appearance == "Escuro" ? .dark : nil)
        .onAppear { if let p = try? JSONDecoder().decode(Preset.self, from: saved) { preset = p } }
        .onChange(of: preset) { p in if let d = try? JSONEncoder().encode(p) { saved = d } }
        .fileExporter(isPresented: $exporting, document: export, contentType: exportType, defaultFilename: exportName) { result in
            switch result { case .success: report("Arquivo exportado."); case .failure(let error): report(error.localizedDescription) }
        }
        .fileImporter(isPresented: $importing, allowedContentTypes: [.json]) { result in
            do {
                let url = try result.get()
                let access = url.startAccessingSecurityScopedResource()
                defer { if access { url.stopAccessingSecurityScopedResource() } }
                let p = try JSONDecoder().decode(Preset.self, from: Data(contentsOf: url))
                guard (0...100).contains(p.battery), ["Sistema","Claro","Escuro"].contains(p.appearance) else { report("Projeto inválido."); return }
                preset = p
                report("Projeto importado.")
            } catch { report(error.localizedDescription) }
        }
        .alert("Milkbunga", isPresented: $alert) { Button("OK", role: .cancel) {} } message: { Text(notice) }
    }
    private func link<Destination: View>(_ title: String, _ symbol: String, _ subtitle: String, _ color: Color, @ViewBuilder destination: () -> Destination) -> some View {
        NavigationLink { destination() } label: {
            HStack(spacing: 14) {
                Image(systemName: symbol).font(.title3.weight(.semibold)).foregroundStyle(color)
                    .frame(width: 46, height: 46).background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.headline).foregroundStyle(.primary)
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right").font(.caption.bold()).foregroundStyle(.tertiary)
            }.padding(12).background(.regularMaterial, in: RoundedRectangle(cornerRadius: 19))
        }.buttonStyle(.plain)
    }
    private var themes: some View {
        Form {
            Section("Prévia do ícone") {
                VStack(spacing: 8) {
                    Group {
                        if let d = iconData, let image = UIImage(data: d) { Image(uiImage: image).resizable().scaledToFill() }
                        else { Image(systemName: "globe").font(.system(size: 34)).frame(maxWidth: .infinity, maxHeight: .infinity).background(.indigo).foregroundStyle(.white) }
                    }.frame(width: 76, height: 76).clipShape(RoundedRectangle(cornerRadius: 18))
                    Text(preset.label).font(.caption)
                }.frame(maxWidth: .infinity).padding()
                PhotosPicker(selection: $photo, matching: .images) { Label("Escolher imagem", systemImage: "photo") }
                    .onChange(of: photo) { item in
                        Task {
                            if let d = try? await item?.loadTransferable(type: Data.self), let im = UIImage(data: d) {
                                let format = UIGraphicsImageRendererFormat(); format.scale = 1
                                let renderer = UIGraphicsImageRenderer(size: CGSize(width: 180, height: 180), format: format)
                                let resized = renderer.image { _ in im.draw(in: CGRect(x: 0, y: 0, width: 180, height: 180)) }
                                iconData = resized.pngData()
                            }
                        }
                    }
            }
            Section("Atalho web") {
                TextField("Nome", text: $preset.label)
                TextField("https://", text: $preset.website).keyboardType(.URL).textInputAutocapitalization(.never).autocorrectionDisabled()
                Button("Exportar .mobileconfig") { createProfile() }
                Text("Cria um Web Clip removível, não substitui o ícone de um aplicativo instalado. Confira o perfil antes de instalar em Ajustes.").font(.caption).foregroundStyle(.secondary)
            }
        }.navigationTitle("Temas e ícones")
    }
    private var status: some View {
        Form {
            Section("Prévia visual — não é a barra real") {
                HStack(spacing: 5) {
                    Text(preset.carrier).lineLimit(1)
                    Spacer()
                    Text(preset.clock).monospacedDigit()
                    Spacer()
                    if preset.cellular { Image(systemName: "cellularbars") }
                    if preset.wifi { Image(systemName: "wifi") }
                    Text("\(preset.battery)%").monospacedDigit()
                    Image(systemName: "battery.100")
                }.font(.caption.bold()).padding(12).foregroundStyle(.white).background(.black, in: RoundedRectangle(cornerRadius: 16))
            }
            Section("Editar prévia") {
                TextField("Operadora", text: $preset.carrier)
                TextField("Hora", text: $preset.clock)
                Stepper("Bateria: \(preset.battery)%", value: $preset.battery, in: 0...100)
                Toggle("Wi-Fi", isOn: $preset.wifi)
                Toggle("Celular", isOn: $preset.cellular)
            }
        }.navigationTitle("Barra de status")
    }
    private var controlCenter: some View {
        ScrollView {
            Text("Prévia interativa. Não controla os rádios do iPhone.").font(.footnote).foregroundStyle(.secondary).padding()
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(["wifi","bluetooth","airplane","flashlight.on.fill","moon.fill","timer"], id: \.self) { symbol in
                    Button {
                        if controls.contains(symbol) { controls.remove(symbol) } else { controls.insert(symbol) }
                    } label: {
                        Image(systemName: symbol).font(.system(size: 28, weight: .medium)).frame(maxWidth: .infinity).frame(height: 98)
                            .foregroundStyle(controls.contains(symbol) ? .white : .primary)
                            .background(controls.contains(symbol) ? Color.indigo : Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 28))
                    }.buttonStyle(.plain).accessibilityLabel(symbol)
                }
            }.padding(.horizontal)
        }.background(Color(uiColor: .systemGroupedBackground)).navigationTitle("Central de Controle")
    }
    private func restricted(_ title: String) -> some View {
        Form {
            Section("Compatibilidade") {
                Label("Não disponível via API pública", systemImage: "lock.shield")
                Text("Esta edição não altera preferências protegidas do iOS, não ativa supervisão e não executa restauração do dispositivo.")
                Button("Abrir Ajustes do app") {
                    if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
                }
            }
        }.navigationTitle(title)
    }
    private func report(_ message: String) { notice = message; alert = true }
    private func savePreset() {
        do { export = ExportFile(data: try JSONEncoder().encode(preset)); exportType = .json; exportName = "Milkbunga-Projeto"; exporting = true }
        catch { report(error.localizedDescription) }
    }
    private func createProfile() {
        let label = preset.label.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !label.isEmpty, let url = URL(string: preset.website), url.scheme?.lowercased() == "https", let host = url.host, !host.isEmpty else {
            report("Informe um nome e um endereço HTTPS válido."); return
        }
        let id = UUID().uuidString
        var clip: [String: Any] = [
            "PayloadType": "com.apple.webClip.managed", "PayloadVersion": 1,
            "PayloadIdentifier": "com.reims.milkbunga.webclip." + id, "PayloadUUID": UUID().uuidString,
            "PayloadDisplayName": label, "Label": label, "URL": url.absoluteString,
            "IsRemovable": true, "FullScreen": false
        ]
        if let data = iconData { clip["Icon"] = data }
        let profile: [String: Any] = [
            "PayloadType": "Configuration", "PayloadVersion": 1,
            "PayloadIdentifier": "com.reims.milkbunga.profile." + id, "PayloadUUID": UUID().uuidString,
            "PayloadDisplayName": "Milkbunga: " + label, "PayloadDescription": "Atalho web removível criado localmente.",
            "PayloadContent": [clip], "PayloadRemovalDisallowed": false
        ]
        do {
            export = ExportFile(data: try PropertyListSerialization.data(fromPropertyList: profile, format: .xml, options: 0))
            exportType = profileType; exportName = "Milkbunga-WebClip.mobileconfig"; exporting = true
        } catch { report(error.localizedDescription) }
    }
}
