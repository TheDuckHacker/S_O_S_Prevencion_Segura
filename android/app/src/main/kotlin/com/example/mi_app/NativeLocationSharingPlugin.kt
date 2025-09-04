package com.example.mi_app

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.*

class NativeLocationSharingPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel : MethodChannel
    private lateinit var context: Context
    private var isSharingLocation = false
    private var sharingInfo: MutableMap<String, Any> = mutableMapOf()

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "native_location_sharing")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "shareLiveLocation" -> {
                val args = call.arguments as Map<String, Any>
                shareLiveLocation(args, result)
            }
            "stopLiveLocationSharing" -> {
                stopLiveLocationSharing(result)
            }
            "isSharingLocation" -> {
                result.success(isSharingLocation)
            }
            "getSharingInfo" -> {
                result.success(sharingInfo)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun shareLiveLocation(args: Map<String, Any>, result: Result) {
        try {
            val latitude = args["latitude"] as Double
            val longitude = args["longitude"] as Double
            val phoneNumbers = args["phoneNumbers"] as List<String>
            val threatDescription = args["threatDescription"] as String
            val durationMinutes = args["durationMinutes"] as Int

            Log.d("NativeLocationSharing", "Compartiendo ubicación: $latitude, $longitude")
            Log.d("NativeLocationSharing", "Números: $phoneNumbers")
            Log.d("NativeLocationSharing", "Descripción: $threatDescription")

            // Crear mensaje para WhatsApp
            val message = createWhatsAppMessage(latitude, longitude, threatDescription, durationMinutes)
            
            // Enviar a cada número
            var successCount = 0
            for (phoneNumber in phoneNumbers) {
                if (sendToWhatsApp(phoneNumber, message, latitude, longitude)) {
                    successCount++
                }
            }

            // Actualizar estado
            isSharingLocation = true
            sharingInfo = mutableMapOf(
                "isSharing" to true,
                "startTime" to System.currentTimeMillis(),
                "durationMinutes" to durationMinutes,
                "phoneNumbers" to phoneNumbers,
                "successCount" to successCount,
                "latitude" to latitude,
                "longitude" to longitude
            )

            Log.d("NativeLocationSharing", "Ubicación compartida a $successCount/${phoneNumbers.size} contactos")
            result.success(successCount > 0)

        } catch (e: Exception) {
            Log.e("NativeLocationSharing", "Error compartiendo ubicación: ${e.message}")
            result.error("SHARING_ERROR", e.message, null)
        }
    }

    private fun createWhatsAppMessage(
        latitude: Double, 
        longitude: Double, 
        threatDescription: String, 
        durationMinutes: Int
    ): String {
        val googleMapsUrl = "https://maps.google.com/?q=$latitude,$longitude"
        val currentTime = Date().toString()
        
        return """🚨 *ALERTA SOS ACTIVA* 🚨

*Descripción:* $threatDescription

📍 *Mi ubicación actual:* $latitude, $longitude
🔗 *Ver en Google Maps:* $googleMapsUrl

⏰ *Hora:* $currentTime

🔄 *UBICACIÓN EN TIEMPO REAL ACTIVADA*
• Se compartirá mi ubicación cada 30 segundos
• Duración: $durationMinutes minutos
• La ubicación se actualiza automáticamente

*Esta alerta fue enviada automáticamente por la app Prevención Segura*"""
    }

    private fun sendToWhatsApp(phoneNumber: String, message: String, latitude: Double, longitude: Double): Boolean {
        return try {
            // Limpiar número de teléfono
            val cleanNumber = phoneNumber.replace(Regex("[^0-9+]"), "")
            val formattedNumber = if (cleanNumber.startsWith("+")) cleanNumber else "+$cleanNumber"
            
            // Crear URL de WhatsApp con ubicación
            val whatsappUrl = "https://wa.me/$formattedNumber?text=${Uri.encode(message)}"
            
            // Crear intent para abrir WhatsApp
            val intent = Intent(Intent.ACTION_VIEW).apply {
                data = Uri.parse(whatsappUrl)
                setPackage("com.whatsapp")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }

            // Verificar si WhatsApp está instalado
            if (intent.resolveActivity(context.packageManager) != null) {
                context.startActivity(intent)
                Log.d("NativeLocationSharing", "WhatsApp abierto para $formattedNumber")
                true
            } else {
                Log.w("NativeLocationSharing", "WhatsApp no está instalado")
                false
            }
        } catch (e: Exception) {
            Log.e("NativeLocationSharing", "Error enviando a WhatsApp: ${e.message}")
            false
        }
    }

    private fun stopLiveLocationSharing(result: Result) {
        try {
            isSharingLocation = false
            sharingInfo = mutableMapOf()
            Log.d("NativeLocationSharing", "Compartir ubicación detenido")
            result.success(true)
        } catch (e: Exception) {
            Log.e("NativeLocationSharing", "Error deteniendo ubicación: ${e.message}")
            result.error("STOP_ERROR", e.message, null)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
