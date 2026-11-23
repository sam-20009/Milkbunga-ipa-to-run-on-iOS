# Milkbunga Mobile — matriz de paridade e teste físico

Fonte de referência: [Cowabunga Lite](https://github.com/leminlimez/CowabungaLite), GPL-3.0; o projeto nativo é uma implementação independente. A fonte original usa executáveis de host e serviços de restauração; o iOS não disponibiliza esses mesmos mecanismos a aplicativos comuns.

| Módulo original | Edição nativa | Teste |
|---|---|---|
| WebClip: nome, ícone, coleção, tela cheia | Exportação de perfil removível, instalação manual | Criar 2 atalhos HTTPS, exportar e conferir cada ícone e URL |
| Ícones de apps instalados sem redirecionamento | Não implementado | Não confundir com WebClip |
| Ocultar nomes dos apps / importação de pasta | Não implementado | N/A |
| Operadora, relógio, bateria, sinal | Prévia local | Alterar valores, fechar e reabrir o aplicativo |
| Central de Controle | Prévia local | Tocar nos controles e verificar feedback visual |
| SpringBoard, rodapé, animações, AirDrop, alertas | Não disponível via API pública | Não executar alterações no sistema |
| Opções internas, diagnóstico e debug | Não implementado | N/A |
| Assistente de configuração, supervisão | Não implementado | Não testar em aparelho pessoal |
| Localização simulada | Não implementado | N/A |
| Operações personalizadas | Não implementado | N/A |

## Testes do IPA
1. Registrar build, versão do iOS, modelo e método de assinatura (sem compartilhar certificados ou chaves).
2. Instalar e abrir; verificar ausência de crash.
3. Verificar tema claro e escuro, navegação e persistência após reabrir.
4. Criar dois atalhos usando imagens diferentes, exportar a coleção, verificar se o perfil contém somente os WebClips esperados. Se optar por instalá-lo, conferir os dados apresentados em Ajustes e remover o perfil depois.
5. Exportar e importar JSON; verificar que valores inválidos são rejeitados.
6. Alterar a barra de status e Central de Controle na prévia, confirmando que não há mudanças no sistema.
7. Relatar: PASS / FAIL / NÃO TESTADO, comportamento observado e captura ou log sem dados privados.

Não há confirmação de compilação ou execução em iOS 27.0.1. O artefato gerado pelo CI é sem assinatura. Não desative Find My ou restaure o aparelho para testar esta versão.
