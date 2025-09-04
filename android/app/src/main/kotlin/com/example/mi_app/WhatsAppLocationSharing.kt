package com.example.mi_app

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log
import java.util.*

class WhatsAppLocationSharing(private val context: Context) {

    companion object {
        private const val TAG = "WhatsAppLocationSharing"
    }

    // Compartir ubicación en tiempo real usando la funcionalidad nativa de WhatsApp
    fun shareLiveLocation(
        phoneNumber: String,
        latitude: Double,
        longitude: Double,
        threatDescription: String,
        durationMinutes: Int
    ): Boolean {
        return try {
            Log.d(TAG, "Iniciando compartir ubicación en tiempo real")
            Log.d(TAG, "Número: $phoneNumber, Lat: $latitude, Lon: $longitude")

            // Limpiar número de teléfono
            val cleanNumber = phoneNumber.replace(Regex("[^0-9+]"), "")
            val formattedNumber = if (cleanNumber.startsWith("+")) cleanNumber else "+$cleanNumber"

            // Crear mensaje para WhatsApp
            val message = createSOSMessage(threatDescription, latitude, longitude, durationMinutes)

            // Intent 1: Usar la funcionalidad nativa de compartir ubicación
            val success1 = tryNativeLocationSharing(formattedNumber, latitude, longitude, message)
            if (success1) {
                Log.d(TAG, "Ubicación compartida usando método nativo")
                return true
            }

            // Intent 2: Usar intent de compartir con ubicación
            val success2 = tryLocationShareIntent(formattedNumber, latitude, longitude, message)
            if (success2) {
                Log.d(TAG, "Ubicación compartida usando intent de compartir")
                return true
            }

            // Intent 3: Usar URL directa de WhatsApp
            val success3 = tryDirectWhatsAppUrl(formattedNumber, message)
            if (success3) {
                Log.d(TAG, "Mensaje enviado usando URL directa")
                return true
            }

            Log.w(TAG, "Todos los métodos fallaron")
            false

        } catch (e: Exception) {
            Log.e(TAG, "Error compartiendo ubicación: ${e.message}")
            false
        }
    }

    private fun tryNativeLocationSharing(phoneNumber: String, latitude: Double, longitude: Double, message: String): Boolean {
        return try {
            // Intent para usar la funcionalidad nativa de compartir ubicación de WhatsApp
            val intent = Intent().apply {
                action = "android.intent.action.SEND"
                type = "text/plain"
                setPackage("com.whatsapp")
                
                // Datos de ubicación
                putExtra("android.intent.extra.LOCATION", "geo:$latitude,$longitude")
                putExtra(Intent.EXTRA_TEXT, message)
                putExtra("android.intent.extra.SUBJECT", "🚨 ALERTA SOS - Ubicación en Tiempo Real")
                
                // Intentar abrir chat específico
                data = Uri.parse("https://wa.me/$phoneNumber")
                
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            }

            if (intent.resolveActivity(context.packageManager) != null) {
                context.startActivity(intent)
                Log.d(TAG, "Intent nativo de ubicación enviado")
                return true
            }
            false
        } catch (e: Exception) {
            Log.e(TAG, "Error en método nativo: ${e.message}")
            false
        }
    }

    private fun tryLocationShareIntent(phoneNumber: String, latitude: Double, longitude: Double, message: String): Boolean {
        return try {
            // Intent alternativo para compartir ubicación
            val intent = Intent().apply {
                action = Intent.ACTION_SEND
                type = "text/plain"
                setPackage("com.whatsapp")
                
                // Mensaje con ubicación
                val locationMessage = "$message\n\n📍 Ubicación: https://maps.google.com/?q=$latitude,$longitude"
                putExtra(Intent.EXTRA_TEXT, locationMessage)
                putExtra("android.intent.extra.SUBJECT", "Ubicación en Tiempo Real")
                
                // Intentar abrir chat específico
                data = Uri.parse("https://wa.me/$phoneNumber")
                
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }

            if (intent.resolveActivity(context.packageManager) != null) {
                context.startActivity(intent)
                Log.d(TAG, "Intent de compartir ubicación enviado")
                return true
            }
            false
        } catch (e: Exception) {
            Log.e(TAG, "Error en intent de compartir: ${e.message}")
            false
        }
    }

    private fun tryDirectWhatsAppUrl(phoneNumber: String, message: String): Boolean {
        return try {
            // URL directa de WhatsApp como último recurso
            val whatsappUrl = "https://wa.me/$phoneNumber?text=${Uri.encode(message)}"
            
            val intent = Intent(Intent.ACTION_VIEW).apply {
                data = Uri.parse(whatsappUrl)
                setPackage("com.whatsapp")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }

            if (intent.resolveActivity(context.packageManager) != null) {
                context.startActivity(intent)
                Log.d(TAG, "URL directa de WhatsApp abierta")
                return true
            }
            false
        } catch (e: Exception) {
            Log.e(TAG, "Error en URL directa: ${e.message}")
            false
        }
    }

    private fun createSOSMessage(threatDescription: String, latitude: Double, longitude: Double, durationMinutes: Int): String {
        val currentTime = Date().toString()
        val googleMapsUrl = "https://maps.google.com/?q=$latitude,$longitude"
        
        return """🚨 *ALERTA SOS ACTIVA* 🚨

*Descripción:* $threatDescription

📍 *Mi ubicación actual:* $latitude, $longitude
🔗 *Ver en Google Maps:* $googleMapsUrl

🌐 *VER UBICACIÓN EN TIEMPO REAL:*
https://s-o-s-prevencion-segura.onrender.com/

⏰ *Hora:* $currentTime

🔄 *UBICACIÓN EN TIEMPO REAL ACTIVADA*
• Se compartirá mi ubicación cada 30 segundos
• Duración: $durationMinutes minutos
• La ubicación se actualiza automáticamente
• Haz clic en el enlace arriba para ver mi ubicación en vivo

*Esta alerta fue enviada automáticamente por la app Prevención Segura*"""
    }

    // Verificar si WhatsApp está instalado
    fun isWhatsAppInstalled(): Boolean {
        return try {
            val intent = Intent().apply {
                setPackage("com.whatsapp")
                action = Intent.ACTION_MAIN
            }
            intent.resolveActivity(context.packageManager) != null
        } catch (e: Exception) {
            Log.e(TAG, "Error verificando WhatsApp: ${e.message}")
            false
        }
    }
}
