import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pesca_app/core/services/backup_service.dart';
import 'package:pesca_app/core/theme/app_theme.dart';
import 'package:pesca_app/core/widgets/pro_badge.dart';
import 'package:pesca_app/features/settings/providers/user_pro_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _stripExifByDefault = true;

  void _exportBackup() {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🔐 Exportar Backup Criptografado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Defina uma senha de criptografia (AES-256) para proteger seus pontos e capturas:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha do Backup',
                prefixIcon: Icon(Icons.key_rounded, color: AppTheme.primaryGreen),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final pwd = passwordController.text.trim();
              if (pwd.length < 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('A senha deve ter pelo menos 4 caracteres.')),
                );
                return;
              }
              Navigator.pop(ctx);
              try {
                final file = await BackupService.exportEncryptedBackup(pwd);
                if (mounted) {
                  await SharePlus.instance.share(
                    ShareParams(
                      files: [XFile(file.path)],
                      subject: 'Meu Backup Criptografado — Diário de Pesca',
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao criar backup: $e')),
                  );
                }
              }
            },
            child: const Text('EXPORTAR'),
          ),
        ],
      ),
    );
  }

  void _restoreBackup() {
    final pathController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('📥 Restaurar Backup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Cole o caminho do arquivo .pescabackup e digite a senha cadastrada:',
                style: TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: pathController,
              decoration: const InputDecoration(
                labelText: 'Caminho do Arquivo (.pescabackup)',
                hintText: '/caminho/do/arquivo.pescabackup',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha do Backup',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final path = pathController.text.trim();
              final pwd = passwordController.text.trim();
              if (path.isEmpty || !File(path).existsSync()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Arquivo não encontrado no caminho informado.')),
                );
                return;
              }
              Navigator.pop(ctx);
              final success = await BackupService.restoreEncryptedBackup(File(path), pwd);
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Backup restaurado com sucesso!'),
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('❌ Senha incorreta ou arquivo inválido.')),
                  );
                }
              }
            },
            child: const Text('RESTAURAR'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPro = ref.watch(userProProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ Configurações & Segurança'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: isPro ? AppTheme.cardBg : AppTheme.surfaceHeader,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isPro ? AppTheme.warningOrange : Colors.transparent,
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isPro ? AppTheme.warningOrange : AppTheme.accentCyan,
                    radius: 24,
                    child: Icon(isPro ? Icons.workspace_premium : Icons.stars, color: Colors.black, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              isPro ? 'Plano PRO Ativo' : 'Plano Gratuito',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            if (isPro) ...[
                              const SizedBox(width: 8),
                              const ProBadge(isCompact: true),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isPro
                              ? 'Acesso ilimitado a equipamentos, estatísticas e backups.'
                              : 'Registros ilimitados de pescarias e mapa local privado.',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (!isPro)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(80, 36),
                        backgroundColor: AppTheme.warningOrange,
                      ),
                      onPressed: () {
                        ref.read(userProProvider.notifier).setProStatus(true);
                      },
                      child: const Text('PRO', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text('Privacidade e EXIF', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              activeThumbColor: AppTheme.primaryGreen,
              title: const Text('Remover GPS/EXIF das Fotos', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text(
                'Apaga coordenadas de localização das fotos antes de compartilhar ou exportar relatórios.',
                style: TextStyle(fontSize: 12),
              ),
              value: _stripExifByDefault,
              onChanged: (val) => setState(() => _stripExifByDefault = val),
            ),
          ),
          const SizedBox(height: 20),

          const Text('Backup & Restauração Local', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_reset_rounded, color: AppTheme.primaryGreen),
                  title: const Text('Exportar Backup Criptografado (AES-256)'),
                  subtitle: const Text('Gera arquivo protegido por senha para salvar em outro aparelho.'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: _exportBackup,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings_backup_restore_rounded, color: AppTheme.accentCyan),
                  title: const Text('Restaurar Backup em Outro Aparelho'),
                  subtitle: const Text('Descriptografa arquivo .pescabackup importando os dados locais.'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: _restoreBackup,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text('Sobre o Aplicativo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('📱 Diário de Pesca v1.0.0', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 6),
                  Text(
                    'Desenvolvido em Flutter para Android & iOS. Operação 100% offline com banco de dados SQLite local e armazenamento seguro.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.offline_pin_rounded, color: AppTheme.primaryGreen, size: 18),
                      SizedBox(width: 6),
                      Text('Modo Offline Ativo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
