package com.playgames.blockblast

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Bundle
import android.view.WindowManager
import androidx.core.view.WindowCompat
import android.media.AudioTrack
import android.media.AudioFormat
import android.media.AudioAttributes
import java.util.concurrent.Executors
import kotlin.math.sin
import kotlin.math.PI
import kotlin.math.exp
import kotlin.math.min
import kotlin.math.max
import kotlin.random.Random

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.playgames.blockblast/audio"
    private val sampleRate = 44100
    private val audioExecutor = Executors.newSingleThreadExecutor()

    override fun onCreate(savedInstanceState: Bundle?) {
        // Activation du mode Edge-to-Edge conforme Android 15
        WindowCompat.setDecorFitsSystemWindows(window, false)
        super.onCreate(savedInstanceState)
        
        // Empêcher l'écran de s'éteindre pendant le jeu
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "playCombo" -> {
                    val streak = call.argument<Int>("streak") ?: 1
                    playComboChime(streak)
                    result.success(true)
                }
                "playBlast" -> {
                    playComboBlast()
                    result.success(true)
                }
                "playPop" -> {
                    playPopSound()
                    result.success(true)
                }
                "playDrop" -> {
                    playDropSound()
                    result.success(true)
                }
                "playHammer" -> {
                    playHammerCrunch()
                    result.success(true)
                }
                "playBomb" -> {
                    playBombExplosion()
                    result.success(true)
                }
                "playVictory" -> {
                    playVictoryFanfare()
                    result.success(true)
                }
                "playDefeat" -> {
                    playDefeatJingle()
                    result.success(true)
                }
                "playCoin" -> {
                    playCoinClink()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun playSoundBuffer(samples: ShortArray) {
        audioExecutor.execute {
            var track: AudioTrack? = null
            try {
                val bufferSize = samples.size * 2
                track = AudioTrack.Builder()
                    .setAudioAttributes(
                        AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_GAME)
                            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                            .build()
                    )
                    .setAudioFormat(
                        AudioFormat.Builder()
                            .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                            .setSampleRate(sampleRate)
                            .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                            .build()
                    )
                    .setBufferSizeInBytes(bufferSize)
                    .setTransferMode(AudioTrack.MODE_STATIC)
                    .build()

                track.write(samples, 0, samples.size)
                track.play()
                
                val durationMs = (samples.size * 1000L) / sampleRate
                Thread.sleep(durationMs + 15)
                track.stop()
            } catch (_: Exception) {
            } finally {
                try {
                    track?.release()
                } catch (_: Exception) {}
            }
        }
    }

    private fun playComboChime(streak: Int) {
        val notes = doubleArrayOf(
            261.63, // C4
            293.66, // D4
            329.63, // E4
            349.23, // F4
            392.00, // G4
            440.00, // A4
            493.88, // B4
            523.25, // C5
            587.33, // D5
            659.25  // E5
        )
        val idx = (streak - 1).coerceIn(0, notes.size - 1)
        val freq = notes[idx]
        val dur = 0.32
        val n = (sampleRate * dur).toInt()
        val samples = ShortArray(n)

        for (i in 0 until n) {
            val t = i.toDouble() / sampleRate
            val attack = min(1.0, t / 0.004)
            val decay = exp(-6.0 * t / dur)
            val env = attack * decay
            val v = (0.58 * sin(2.0 * PI * freq * t) +
                     0.26 * sin(4.0 * PI * freq * t) +
                     0.11 * sin(6.0 * PI * freq * t) +
                     0.05 * sin(8.0 * PI * freq * t)) * env * 27000.0
            val s16 = max(-32767.0, min(32767.0, v)).toInt()
            samples[i] = s16.toShort()
        }
        playSoundBuffer(samples)
    }

    private fun playComboBlast() {
        val dur = 0.55
        val n = (sampleRate * dur).toInt()
        val samples = ShortArray(n)
        val notes = doubleArrayOf(523.25, 659.25, 783.99, 1046.50)

        for (idx in notes.indices) {
            val freq = notes[idx]
            val start = (idx * 0.07 * sampleRate).toInt()
            val noteN = (sampleRate * 0.30).toInt()
            for (j in 0 until noteN) {
                if (start + j < n) {
                    val t = j.toDouble() / sampleRate
                    val env = min(1.0, t / 0.004) * exp(-6.0 * t / 0.30)
                    val v = sin(2.0 * PI * freq * t) * env * 12000.0
                    val existing = samples[start + j].toInt()
                    val combined = max(-32767.0, min(32767.0, existing + v)).toInt()
                    samples[start + j] = combined.toShort()
                }
            }
        }
        playSoundBuffer(samples)
    }

    private fun playPopSound() {
        val dur = 0.07
        val n = (sampleRate * dur).toInt()
        val samples = ShortArray(n)
        for (i in 0 until n) {
            val t = i.toDouble() / sampleRate
            val f = 450.0 + 350.0 * (t / dur)
            val env = sin(PI * (t / dur))
            val v = sin(2.0 * PI * f * t) * env * 22000.0
            samples[i] = max(-32767.0, min(32767.0, v)).toInt().toShort()
        }
        playSoundBuffer(samples)
    }

    private fun playDropSound() {
        val dur = 0.09
        val n = (sampleRate * dur).toInt()
        val samples = ShortArray(n)
        for (i in 0 until n) {
            val t = i.toDouble() / sampleRate
            val f = 380.0 - 160.0 * (t / dur)
            val env = exp(-24.0 * t)
            val v = (sin(2.0 * PI * f * t) + 0.3 * sin(4.0 * PI * f * t)) * env * 25000.0
            samples[i] = max(-32767.0, min(32767.0, v)).toInt().toShort()
        }
        playSoundBuffer(samples)
    }

    private fun playHammerCrunch() {
        val dur = 0.20
        val n = (sampleRate * dur).toInt()
        val samples = ShortArray(n)
        val rng = Random(42)
        for (i in 0 until n) {
            val t = i.toDouble() / sampleRate
            val thud = sin(2.0 * PI * (130.0 - 60.0 * (t / dur)) * t) * exp(-20.0 * t) * 18000.0
            val noise = (rng.nextDouble() * 2.0 - 1.0) * exp(-35.0 * t) * 16000.0
            val combined = max(-32767.0, min(32767.0, thud + noise)).toInt()
            samples[i] = combined.toShort()
        }
        playSoundBuffer(samples)
    }

    private fun playBombExplosion() {
        val dur = 0.38
        val n = (sampleRate * dur).toInt()
        val samples = ShortArray(n)
        val rng = Random(99)
        for (i in 0 until n) {
            val t = i.toDouble() / sampleRate
            val fBass = max(35.0, 130.0 - 170.0 * t)
            val bass = sin(2.0 * PI * fBass * t) * exp(-7.0 * t) * 20000.0
            val fizz = (rng.nextDouble() * 2.0 - 1.0) * exp(-14.0 * t) * 13000.0
            val combined = max(-32767.0, min(32767.0, bass + fizz)).toInt()
            samples[i] = combined.toShort()
        }
        playSoundBuffer(samples)
    }

    private fun playVictoryFanfare() {
        val dur = 0.80
        val n = (sampleRate * dur).toInt()
        val samples = ShortArray(n)
        val chords = doubleArrayOf(392.00, 523.25, 659.25, 783.99, 1046.50)
        for (idx in chords.indices) {
            val freq = chords[idx]
            val start = (idx * 0.09 * sampleRate).toInt()
            val noteN = (sampleRate * 0.35).toInt()
            for (j in 0 until noteN) {
                if (start + j < n) {
                    val t = j.toDouble() / sampleRate
                    val env = min(1.0, t / 0.004) * exp(-5.0 * t / 0.35)
                    val v = (0.6 * sin(2.0 * PI * freq * t) + 0.3 * sin(4.0 * PI * freq * t)) * env * 11000.0
                    val existing = samples[start + j].toInt()
                    val combined = max(-32767.0, min(32767.0, existing + v)).toInt()
                    samples[start + j] = combined.toShort()
                }
            }
        }
        playSoundBuffer(samples)
    }

    private fun playDefeatJingle() {
        val dur = 0.50
        val n = (sampleRate * dur).toInt()
        val samples = ShortArray(n)
        val chords = doubleArrayOf(392.00, 349.23, 311.13, 261.63)
        for (idx in chords.indices) {
            val freq = chords[idx]
            val start = (idx * 0.10 * sampleRate).toInt()
            val noteN = (sampleRate * 0.28).toInt()
            for (j in 0 until noteN) {
                if (start + j < n) {
                    val t = j.toDouble() / sampleRate
                    val env = min(1.0, t / 0.005) * exp(-5.5 * t / 0.28)
                    val v = sin(2.0 * PI * freq * t) * env * 11000.0
                    val existing = samples[start + j].toInt()
                    val combined = max(-32767.0, min(32767.0, existing + v)).toInt()
                    samples[start + j] = combined.toShort()
                }
            }
        }
        playSoundBuffer(samples)
    }

    private fun playCoinClink() {
        val dur = 0.18
        val n = (sampleRate * dur).toInt()
        val samples = ShortArray(n)
        for (i in 0 until n) {
            val t = i.toDouble() / sampleRate
            val env = exp(-16.0 * t)
            val c1 = sin(2.0 * PI * 1318.5 * t)
            val c2 = sin(2.0 * PI * 2093.0 * t)
            val v = (c1 * 0.6 + c2 * 0.4) * env * 22000.0
            samples[i] = max(-32767.0, min(32767.0, v)).toInt().toShort()
        }
        playSoundBuffer(samples)
    }
}
