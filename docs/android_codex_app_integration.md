# Android App Integration

This project exposes a small HTTP API that an Android app can poll or post to.
It is intentionally simple so the capstone demo still works without ESP32,
Raspberry Pi, or webcam hardware.

## 1. Start the API server

From Windows PowerShell at the project root:

```powershell
.\scripts\run_android_api.ps1
```

The script starts FastAPI on `0.0.0.0:8000`, which makes it reachable from
other devices on the same Wi-Fi network.

If Windows Firewall asks for permission, allow private-network access for
Python. Without that, the Android phone may not reach the server.

## 2. Find the PC IP address

Run:

```powershell
ipconfig
```

Use the IPv4 address of the Wi-Fi adapter. For example, if the PC IP is
`192.168.0.23`, configure the Android app base URL as:

```text
http://192.168.0.23:8000
```

Android emulators can usually use this base URL instead:

```text
http://10.0.2.2:8000
```

## 3. Endpoints for the Android app

Health check:

```http
GET /health
```

Read integrated CSI and camera status:

```http
GET /status
```

Read endpoint metadata:

```http
GET /app_config
```

Seed mock demo data:

```http
POST /demo/mock_status
```

Post CSI results:

```http
POST /csi_result
Content-Type: application/json

{
  "presence": true,
  "motion": true,
  "activity": "walking",
  "confidence": 0.82
}
```

Post camera pose results:

```http
POST /pose_result
Content-Type: application/json

{
  "human": true,
  "posture": "standing",
  "avg_confidence": 0.91,
  "num_valid_keypoints": 27
}
```

## 4. Example Android client

Kotlin with OkHttp:

```kotlin
val client = OkHttpClient()
val baseUrl = "http://192.168.0.23:8000"

val request = Request.Builder()
    .url("$baseUrl/status")
    .get()
    .build()

client.newCall(request).enqueue(object : Callback {
    override fun onFailure(call: Call, e: IOException) {
        Log.e("CsiPoseApi", "API request failed", e)
    }

    override fun onResponse(call: Call, response: Response) {
        response.use {
            val json = it.body?.string().orEmpty()
            Log.d("CsiPoseApi", json)
        }
    }
})
```

For a real Android app, keep the base URL in a debug build config or local
settings screen rather than hard-coding one classroom IP address.

## 5. Quick test from Android or another device

Open this in the phone browser:

```text
http://<this-PC-LAN-IP>:8000/health
```

If it returns JSON with `"status": "ok"`, the Android app can connect.

