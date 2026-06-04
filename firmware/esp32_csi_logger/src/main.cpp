#include <Arduino.h>
#include <WiFi.h>

extern "C" {
#include "esp_wifi.h"
#include "esp_event.h"
}

#ifndef CSI_AP_SSID
#define CSI_AP_SSID "CSI_CAPSTONE_AP"
#endif

#ifndef CSI_AP_PASSWORD
#define CSI_AP_PASSWORD ""
#endif

static volatile uint32_t g_csi_count = 0;
static uint32_t g_last_status_ms = 0;

static void print_mac(const uint8_t *mac) {
  for (int i = 0; i < 6; ++i) {
    if (i) Serial.print(":");
    if (mac[i] < 16) Serial.print("0");
    Serial.print(mac[i], HEX);
  }
}

static void csi_callback(void *ctx, wifi_csi_info_t *info) {
  (void)ctx;
  if (info == nullptr || info->buf == nullptr || info->len <= 0) {
    return;
  }

  g_csi_count++;

  Serial.print("CSI_DATA,");
  Serial.print(millis());
  Serial.print(",");
  print_mac(info->mac);
  Serial.print(",");
  Serial.print(info->rx_ctrl.rssi);
  Serial.print(",");
  Serial.print(info->rx_ctrl.channel);
  Serial.print(",");
  Serial.print(info->len);
  Serial.print(",[");
  for (int i = 0; i < info->len; ++i) {
    if (i) Serial.print(",");
    Serial.print(info->buf[i]);
  }
  Serial.println("]");
}

static void configure_csi() {
  wifi_csi_config_t csi_config = {};
  csi_config.lltf_en = true;
  csi_config.htltf_en = true;
  csi_config.stbc_htltf2_en = true;
  csi_config.ltf_merge_en = true;
  csi_config.channel_filter_en = false;
  csi_config.manu_scale = false;
  csi_config.shift = 0;

  esp_err_t err = esp_wifi_set_csi_config(&csi_config);
  if (err != ESP_OK) {
    Serial.printf("CSI_CONFIG_ERROR,%d\n", err);
  }

  err = esp_wifi_set_csi_rx_cb(csi_callback, nullptr);
  if (err != ESP_OK) {
    Serial.printf("CSI_CALLBACK_ERROR,%d\n", err);
  }

  err = esp_wifi_set_csi(true);
  if (err != ESP_OK) {
    Serial.printf("CSI_ENABLE_ERROR,%d\n", err);
  } else {
    Serial.println("CSI_READY");
  }
}

static void start_softap() {
  WiFi.mode(WIFI_AP);
  WiFi.setSleep(false);

  const char *password = CSI_AP_PASSWORD;
  bool has_password = strlen(password) >= 8;
  bool ok = WiFi.softAP(CSI_AP_SSID, has_password ? password : nullptr, 6, false, 4);

  Serial.print("AP_START,ssid=");
  Serial.print(CSI_AP_SSID);
  Serial.print(",ok=");
  Serial.print(ok ? "true" : "false");
  Serial.print(",ip=");
  Serial.println(WiFi.softAPIP());

  esp_wifi_set_promiscuous(true);
  configure_csi();
}

void setup() {
  Serial.begin(921600);
  delay(1200);

  Serial.println();
  Serial.println("ESP32_S3_CSI_LOGGER_BOOT");
  Serial.println("SERIAL_BAUD,921600");
  Serial.println("MODE,softap_csi_receiver");
  start_softap();
}

void loop() {
  uint32_t now = millis();
  if (now - g_last_status_ms >= 2000) {
    g_last_status_ms = now;
    Serial.print("CSI_STATUS,count=");
    Serial.print(g_csi_count);
    Serial.print(",stations=");
    Serial.print(WiFi.softAPgetStationNum());
    Serial.print(",ssid=");
    Serial.println(CSI_AP_SSID);
  }
  delay(20);
}

