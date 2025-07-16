package com.example.gps_tracker

import android.annotation.SuppressLint
import android.content.Context
import android.os.Looper
import android.view.View
import android.webkit.WebView
import android.webkit.WebViewClient
import com.google.android.gms.location.*
import io.flutter.plugin.platform.PlatformView

class OlaMapView(context: Context) : PlatformView {

    private val webView = WebView(context)
    private val fusedLocationClient = LocationServices.getFusedLocationProviderClient(context)
    private val locationRequest: LocationRequest
    private val locationCallback: LocationCallback

    init {
        webView.webViewClient = WebViewClient()
        webView.settings.javaScriptEnabled = true

        locationRequest = LocationRequest.create().apply {
            interval = 10000 // update every 10 seconds
            fastestInterval = 5000
            priority = Priority.PRIORITY_HIGH_ACCURACY
        }

        locationCallback = object : LocationCallback() {
            override fun onLocationResult(result: LocationResult) {
                val location = result.lastLocation
                if (location != null) {
                    val mapUrl = "https://partner.olaelectric.com/map?lat=${location.latitude}&lng=${location.longitude}"
                    webView.loadUrl(mapUrl)
                }
            }
        }

        startLocationUpdates()
    }

    @SuppressLint("MissingPermission")
    private fun startLocationUpdates() {
        fusedLocationClient.requestLocationUpdates(
            locationRequest,
            locationCallback,
            Looper.getMainLooper()
        )
    }

    override fun getView(): View = webView

    override fun dispose() {
        webView.destroy()
        fusedLocationClient.removeLocationUpdates(locationCallback)
    }
}
