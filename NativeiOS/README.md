# Milkbunga Mobile — iOS 0.1.0

Reconstrução nativa em SwiftUI, separada do aplicativo desktop. A árvore original não contém os arquivos Swift referidos pelo projeto Xcode; o README indica um ZIP complementar indisponível à conexão usada. Não é um porte integral nem oferece alterações de arquivos protegidos.

## Funcionalidades
- Criação local de perfil de Web Clip HTTPS removível, com imagem opcional escolhida pelo usuário. Exportação, seguida de instalação manual se o iOS aceitar o perfil.
- Editor de prévia da barra de status e da central de controle, explicitamente apenas visual.
- Preferências persistentes e importação/exportação de projetos JSON.
- Detecção da versão real do iOS. Tema claro/escuro/sistema.
- Não modifica Find My, supervisão, setup, backups ou configurações protegidas.
- Não há dependência de Mac em tempo de execução. A compilação ocorre no CI.

## Compilação
GitHub Actions: Milkbunga iOS - build unsigned IPA. O artefato é um IPA sem assinatura, que necessita assinatura e provisionamento compatíveis com o dispositivo. O build no CI não comprova execução física. Requer iOS 16+.

Localmente no macOS: instale Xcode e XcodeGen, execute xcodegen generate nesta pasta e abra o projeto. Configure seu Team antes de instalar.

Interface original: projeto Milkbunga/Cowabunga Lite. Reconstrução independente, sem reutilizar binários desktop.
