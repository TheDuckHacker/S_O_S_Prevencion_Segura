import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/whatsapp_business_api.dart';
import '../utils/app_colors.dart';

class WhatsAppConfigScreen extends StatefulWidget {
  const WhatsAppConfigScreen({super.key});

  @override
  State<WhatsAppConfigScreen> createState() => _WhatsAppConfigScreenState();
}

class _WhatsAppConfigScreenState extends State<WhatsAppConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accessTokenController = TextEditingController();
  final _phoneNumberIdController = TextEditingController();
  final _businessAccountIdController = TextEditingController();
  
  bool _isLoading = false;
  bool _isConfigured = false;

  @override
  void initState() {
    super.initState();
    _checkConfiguration();
  }

  @override
  void dispose() {
    _accessTokenController.dispose();
    _phoneNumberIdController.dispose();
    _businessAccountIdController.dispose();
    super.dispose();
  }

  Future<void> _checkConfiguration() async {
    setState(() {
      _isConfigured = WhatsAppBusinessAPI.isConfigured();
    });
  }

  Future<void> _saveConfiguration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await WhatsAppBusinessAPI.configure(
        accessToken: _accessTokenController.text.trim(),
        phoneNumberId: _phoneNumberIdController.text.trim(),
        businessAccountId: _businessAccountIdController.text.trim(),
      );

      setState(() {
        _isConfigured = true;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ WhatsApp Business API configurada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error configurando: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearConfiguration() async {
    await WhatsAppBusinessAPI.clearConfiguration();
    setState(() {
      _isConfigured = false;
      _accessTokenController.clear();
      _phoneNumberIdController.clear();
      _businessAccountIdController.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Configuración eliminada'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final info = await WhatsAppBusinessAPI.getAccountInfo();
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Información de la Cuenta'),
            content: info != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: ${info['id'] ?? 'N/A'}'),
                      Text('Nombre: ${info['name'] ?? 'N/A'}'),
                      Text('Estado: ${info['status'] ?? 'N/A'}'),
                    ],
                  )
                : const Text('No se pudo obtener información'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error probando conexión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Configuración WhatsApp Business'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estado actual
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isConfigured ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isConfigured ? Colors.green : Colors.orange,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isConfigured ? Icons.check_circle : Icons.warning,
                    color: _isConfigured ? Colors.green : Colors.orange,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isConfigured
                          ? 'WhatsApp Business API configurada correctamente'
                          : 'WhatsApp Business API no configurada',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _isConfigured ? Colors.green.shade800 : Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Información
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade600, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        '¿Cómo obtener las credenciales?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '1. Ve a developers.facebook.com\n'
                    '2. Crea una aplicación de WhatsApp Business\n'
                    '3. Obtén tu Access Token\n'
                    '4. Configura tu Phone Number ID\n'
                    '5. Obtén tu Business Account ID',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Formulario de configuración
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Credenciales de WhatsApp Business API',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Access Token
                  TextFormField(
                    controller: _accessTokenController,
                    decoration: InputDecoration(
                      labelText: 'Access Token',
                      hintText: 'EAAxxxxxxxxxxxxxxxxxxxxx',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.key),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El Access Token es requerido';
                      }
                      return null;
                    },
                    obscureText: true,
                  ),

                  const SizedBox(height: 16),

                  // Phone Number ID
                  TextFormField(
                    controller: _phoneNumberIdController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number ID',
                      hintText: '123456789012345',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.phone),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El Phone Number ID es requerido';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 16),

                  // Business Account ID
                  TextFormField(
                    controller: _businessAccountIdController,
                    decoration: InputDecoration(
                      labelText: 'Business Account ID',
                      hintText: '123456789012345',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.business),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El Business Account ID es requerido';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 24),

                  // Botones
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveConfiguration,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Guardar Configuración',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _testConnection,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Probar Conexión'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _clearConfiguration,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Limpiar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
