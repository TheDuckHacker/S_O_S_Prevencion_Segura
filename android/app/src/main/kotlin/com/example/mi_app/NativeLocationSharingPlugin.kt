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
    private lateinit var whatsAppLocationSharing: WhatsAppLocationSharing

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "native_location_sharing")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        whatsAppLocationSharing = WhatsAppLocationSharing(context)
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
            
            // Enviar a cada número usando la nueva implementación
            var successCount = 0
            for (phoneNumber in phoneNumbers) {
                if (whatsAppLocationSharing.shareLiveLocation(
                    phoneNumber = phoneNumber,
                    latitude = latitude,
                    longitude = longitude,
                    threatDescription = threatDescription,
                    durationMinutes = durationMinutes
                )) {
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
            
            Log.d("NativeLocationSharing", "Intentando compartir ubicación en tiempo real con $formattedNumber")
            
            // Intentar usar la funcionalidad nativa de WhatsApp para compartir ubicación
            val success = shareLiveLocationNative(formattedNumber, latitude, longitude, message)
            
            if (success) {
                Log.d("NativeLocationSharing", "Ubicación en tiempo real compartida exitosamente")
                return true
            }
            
            // Fallback: usar método tradicional
            Log.d("NativeLocationSharing", "Usando método tradicional como fallback")
            val whatsappUrl = "https://wa.me/$formattedNumber?text=${Uri.encode(message)}"
            
            val intent = Intent(Intent.ACTION_VIEW).apply {
                data = Uri.parse(whatsappUrl)
                setPackage("com.whatsapp")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }

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

    private fun shareLiveLocationNative(phoneNumber: String, latitude: Double, longitude: Double, message: String): Boolean {
        return try {
            // Crear intent para compartir ubicación en tiempo real usando la API nativa de WhatsApp
            val intent = Intent().apply {
                action = Intent.ACTION_SEND
                type = "text/plain"
                setPackage("com.whatsapp")
                
                // Intentar usar la funcionalidad de ubicación en tiempo real
                putExtra(Intent.EXTRA_TEXT, message)
                putExtra("android.intent.extra.LOCATION", "geo:$latitude,$longitude")
                putExtra("android.intent.extra.SUBJECT", "Ubicación en Tiempo Real - SOS")
                
                // Intentar abrir directamente el chat con el número
                data = Uri.parse("https://wa.me/$phoneNumber")
                
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            }

            // Verificar si WhatsApp puede manejar este intent
            if (intent.resolveActivity(context.packageManager) != null) {
                context.startActivity(intent)
                Log.d("NativeLocationSharing", "Intent nativo enviado a WhatsApp")
                return true
            }

            // Segundo intent: usar la funcionalidad de compartir ubicación
            val locationIntent = Intent().apply {
                action = Intent.ACTION_SEND
                type = "text/plain"
                setPackage("com.whatsapp")
                putExtra(Intent.EXTRA_TEXT, "🚨 COMPARTIR UBICACIÓN EN TIEMPO REAL 🚨\n\n$message")
                putExtra("android.intent.extra.LOCATION", "geo:$latitude,$longitude")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }

            if (locationIntent.resolveActivity(context.packageManager) != null) {
                context.startActivity(locationIntent)
                Log.d("NativeLocationSharing", "Intent de ubicación enviado a WhatsApp")
                return true
            }

            Log.w("NativeLocationSharing", "WhatsApp no puede manejar intents nativos de ubicación")
            false
        } catch (e: Exception) {
            Log.e("NativeLocationSharing", "Error en shareLiveLocationNative: ${e.message}")
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
